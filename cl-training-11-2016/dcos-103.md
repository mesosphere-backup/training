# DC/OS 103 - Service Discovery

Service Discovery is the process of finding out the `IP:PORT` combination a service is available from in a cluster of machines.
Mesos Master is the ultimate source of truth concerning this information and as such any Service Discovery (SD) mechanisms need
to consult it to learn about the mapping of a Mesos task (== service instance) to IP and port. 

https://gist.github.com/mhausenblas/7aba37703f9669576b00e973ae6a50c8
