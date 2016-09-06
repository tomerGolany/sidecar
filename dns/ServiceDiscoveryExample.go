package dns

import (
	"github.com/amalgam8/registry/client"
	"net/url"

)

func CreateNewClient() (client.Client, error) {
	conf := client.Config{URL: "http://172.17.0.02:8080"}
	return client.New(conf)
}

func CreateDNSServer() (*Server, error){
	myclient, _ := CreateNewClient()
	dnsConfig := Config{
		DiscoveryClient: myclient ,
		Port:            8053,
		Domain:          "amalgam8",
	}
	return NewServer(dnsConfig)

}

type MySimpleServiceDiscovery struct {
	services []*client.ServiceInstance

}


// ListServices queries the registry for the list of services for which instances are currently registered.
func (m *MySimpleServiceDiscovery ) ListServices() ([]string, error) {
	servicesNames := []string{}
	for _, service := range m.services {
		servicesNames = append(servicesNames,service.ServiceName)
	}
	return servicesNames, nil
}

// ListInstances queries the registry for the list of service instances currently registered.
// The given InstanceFilter can be used to filter the returned instances as well as the fields returned for each.
func (m *MySimpleServiceDiscovery ) ListInstances(filter client.InstanceFilter) ([]*client.ServiceInstance, error){

	servicesToReturn := []*client.ServiceInstance{}
	count := 0
	for _, service := range m.services {
		if service.ServiceName == filter.ServiceName {
			for _, tag := range filter.Tags {
				for _, serviceTag := range service.Tags {
					if tag == serviceTag {
						count++
					}
				}
			}
			if count == len(filter.Tags) {
				servicesToReturn = append(servicesToReturn, service)

			}
		}
	}
	return servicesToReturn, nil
}

// ListServiceInstances queries the registry for the list of service instances with status 'UP' currently
// registered for the given service.
func (m *MySimpleServiceDiscovery ) ListServiceInstances(serviceName string) ([]*client.ServiceInstance, error) {

	servicesToReturn := []*client.ServiceInstance{}
	for _, service := range m.services {
		if service.ServiceName == serviceName {
			servicesToReturn = append(servicesToReturn,service)

		}

	}
	return servicesToReturn, nil
}


func CreateExampleServiceDiscovery() (*MySimpleServiceDiscovery){
	m := new(MySimpleServiceDiscovery)
	url1 := url.URL{
		Scheme:  "http",
		Host:    "amalgam8",
		Path:    "/shopping/cart",
	}
	url2 := url.URL{
		Scheme:  "http",
		Host:    "amalgam8",
		Path:    "/Orders",
	}

	m.services = append(m.services ,&client.ServiceInstance{ServiceName:"shoppingCart", ID: "1", Endpoint: client.NewHTTPEndpoint(url1)})
	m.services = append(m.services, &client.ServiceInstance{ServiceName:"shoppingCart", ID: "2", Endpoint: client.NewTCPEndpoint("127.0.0.5", 5050)})
	m.services = append(m.services, &client.ServiceInstance{Tags: []string{"first","second"}, ServiceName:"shoppingCart", ID: "3", Endpoint: client.NewTCPEndpoint("127.0.0.4", 5050)})
	m.services = append(m.services, &client.ServiceInstance{ServiceName:"Orders", ID: "4", Endpoint: client.NewTCPEndpoint("127.0.0.10", 3050)})
	m.services = append(m.services, &client.ServiceInstance{ServiceName:"Orders", ID: "6", Endpoint: client.NewHTTPEndpoint(url2)})
	m.services = append(m.services, &client.ServiceInstance{ServiceName:"Orders", ID: "7", Endpoint: client.NewTCPEndpoint("132.68.5.6", 1010)})
	m.services = append(m.services, &client.ServiceInstance{ServiceName:"Reviews", ID: "8", Endpoint: client.NewTCPEndpoint("132.68.5.6", 1010)})
	return m
}

