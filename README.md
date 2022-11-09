
The deployment consists of two services with dockers, one for nodejs and one for react. Two load balancers
were deployed to send the requests to the services. The dns names for the load balancers were used for routing
the requests.

For simplicity, one VPC was used without any subnetting. Both services are publicly accesible.

The final url to see it in action:
http://reactlb-2088109173.us-east-1.elb.amazonaws.com


See the detailed_instructions for the complete set of steps. 



CI/CD

I have put things in place for CI/CD on the react component. Built my code pipeline, put in buildspec.yml in frontend, Dockerfile at the root level. 
Made one simple change to frontend/src/App.js - the fetching message that appears at the beginning.

I have not yet provided the details for this step in the detailed_instructions. Waiting to make sure it works completely before doing that.

Right now I have reached the limit on pull requests for Alpine. Waiting for the timeout. 
