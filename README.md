
The deployment consists of two services with dockers, one for nodejs and one for react. Two load balancers
were deployed to send the requests to the services. The dns names for the load balancers were used for routing
the requests.

For simplicity, one VPC was used without any subnetting. Both services are publicly accesible.

The final url to see it in action:
http://reactlb-2088109173.us-east-1.elb.amazonaws.com


See the detailed_instructions for the complete set of steps. 



CI/CD

I have put things in place for CI/CD on the react component. Built my code pipeline, put in buildspec.yml in frontend, Dockerfile at the root level. 
Made one simple change to frontend/src/App.js - the fetching message that appears at the beginning. It goes by so quick that its hard to see, but it is there. You can make another change that is more visible. The build and deploy process is taking about 10 to 15 minutes.

 
