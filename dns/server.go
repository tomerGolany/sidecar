// Copyright 2016 IBM Corporation
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

package dns

import (
	"fmt"
	"net"

	"github.com/Sirupsen/logrus"
	"github.com/amalgam8/registry/client"
	"github.com/miekg/dns"
)

type Server struct {
	config    Config
	discovery client.Discovery

	dnsServer *dns.Server
}

type Config struct {
	DiscoveryClient client.Discovery
	Port            uint16
	Domain          string
}

func NewServer(config Config) (*Server, error) {
	err := validate(&config)
	if err != nil {
		return nil, err
	}

	s := &Server{
		config: config,
	}

	// Setup DNS muxing
	mux := dns.NewServeMux()
	mux.HandleFunc(config.Domain, s.handleRequest)

	// Setup a DNS server
	s.dnsServer = &dns.Server{
		Addr:    fmt.Sprintf(":%d", config.Port),
		Net:     "udp",
		Handler: mux,
	}

	return s, nil
}

func (s *Server) ListenAndServe() error {
	logrus.Info("Starting DNS server")
	err := s.dnsServer.ListenAndServe()

	if err != nil {
		logrus.WithError(err).Errorf("Error starting DNS server")
	}

	return nil
}

func (s *Server) Shutdown() error {
	logrus.Info("Shutting down DNS server")
	err := s.dnsServer.Shutdown()

	if err != nil {
		logrus.WithError(err).Errorf("Error shutting down DNS server")
	} else {
		logrus.Info("DNS server has shutdown")
	}

	return err
}

func (s *Server) handleRequest(w dns.ResponseWriter, request *dns.Msg) {
	response := new(dns.Msg)
	response.SetReply(request)
	response.Authoritative = true
	response.RecursionAvailable = false

	for i, question := range request.Question {
		err := s.handleQuestion(question, request, response)
		if err != nil {
			logrus.WithError(err).Errorf("Error handling DNS question %d: %s", i, question.String())
			break
		}
	}

	err := w.WriteMsg(response)
	if err != nil {
		logrus.WithError(err).Errorf("Error writing DNS response")
	}
}

func (s *Server) handleQuestion(question dns.Question, request, response *dns.Msg) error {

	switch question.Qclass {
	case dns.ClassINET:
	default:
		response.SetRcode(request, dns.RcodeServerFailure)
		return fmt.Errorf("unsupported DNS question class: %v", dns.Class(question.Qclass).String())
	}

	switch question.Qtype {
	case dns.TypeA:
	case dns.TypeANY:
	default:
		response.SetRcode(request, dns.RcodeServerFailure)
		return fmt.Errorf("unsupported DNS question type: %v", dns.Type(question.Qtype).String())
	}

	// Query format:
	// [tag]*.<service>.<domain>.
	parts := dns.SplitDomainName(question.Name)
	if len(parts) <= 2 {
		return fmt.Errorf("")
	}

	// Add A record
	record := &dns.A{
		Hdr: dns.RR_Header{
			Name:   question.Name,
			Rrtype: dns.TypeA,
			Class:  dns.ClassINET,
			Ttl:    0,
		},
		A: net.ParseIP("127.0.0.66"),
	}

	response.Answer = append(response.Answer, record)

	return nil
}

func validate(config *Config) error {
	// TODO: Validate port
	if config.DiscoveryClient == nil {
		return fmt.Errorf("Discovery client is nil")
	}
	config.Domain = dns.Fqdn(config.Domain)

	return nil
}
