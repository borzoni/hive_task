# Task Completion Notes
Hey, I decided to challenge myself and develop something useful as a thing.
The thing that always amazed me during my Ruby career that at every project I collaborated on, people develop various solutions for the service object pattern. 
Frankly, I didn't liked either of the solutions, but the convention was kind of settled and I didn't have time to articulate my feelings about what makes a good service objects.
So, I sat down and came with this thoughts:
* Service object needs to enforce a contract.
* Service object needs to be composable. Sorry, my FP background :)
* Service object should enforce testability and use some kind of DI

So, I decided to adopt something really close to my heart and picked dry-rb stack and integrated only the parts that I needed and I can advocate that the developed solution solves all the goals stated above with nice minimal API. What's more - this solution can work with nested transactions seamlessly and without type splitting on the traits like 'WithTransaction' or whatever. That's the feature I like the most. 
Remember I prioritized the maximal composability - so transactions and all the other cross stuff shouldn't change compasability guaranties stated with monadic interface on Result type(shortcircuiting included)

Other bell and whistles included
* Swagger docs
* jwt auth
* Grape api with some of the modifications that i believe makes the api creation comfortable and safe.
* Rspecs for interactors and main task

Thoughts on improvements
* Tests on controller should be splitted for serializers and request specs, really should be done if serializers continues to evolve and new views are added.
* The RestockingInteractor is the most bacis one, so I can't demonstrate enforced testability and composability with DI via dry-initilizer, so maybe some kind of merge logic can be thought (if there are some restocks for the same day - then recalculate quantites and shipping cost and so on). So with this reqs with would have new Merger interactor that would be passed with like 
`option :merger, default: -> { MergerImpl }` 
And we can easily stub it, we can enclose in the transaction, and not to mention how clean it looks when we can see all the dependencies on the top of the interactor.
# Coding Challenge with Hive

Hey 👋 We're happy you're here! To give you a taste of life at Hive, we wanted to use an example that's as close to the day-to-day work you'll encounter as possible. This challenge is a (simplified version of) a real feature we've built some time ago at Hive. 

### Expected outcome
Please **clone** this repo, upload your results as a PR in a new private repo, and give us (github users: `lvkleist`, `lukasklinser`) access when you're done.

### User Story

As a shop owner, I want to be able to announce a restocking shipment whenever I need to fill up my inventory in Hive's warehouse.

#### Context
**What's a restocking shipment**: With `Restocking shipment` we concretely mean that a shop owner announces new inventory coming to Hive's warehouse at a specific point in time. You can imagine a shop selling different t-shirts (e.g. white, black and blue) and the white one almost being out of stock. In that case, the shop owner will likely re-order the white t-shirts and announce to us that there will be an inbound delivery.

#### What we value
We don't care whether you're done in 2 hours or take 7 hours to complete the tasks below. Here's a brief overview of what we'd like to see in your submission →

* Try to stick to what you'd want to see in "production-level code". This, to us, means solid unit testing (not just the happy case), adapting to our existing coding conventions (example: if you see that we use the blueprinter gem to return JSON data, adopt this convention), and organizing your code in a maintable way (example: using Service Objects when this makes sense for readability and reusability).
* If you have questions, ask — you wouldn't just deploy code if you're uncertain in any other setting either, so feel free to reach out if anything is unclear :)

#### What's next
Once you submit a PR on your new repo containing your solution, we'll do a code review to ask questions, give feedback and suggest improvements.

--


### Tasks
# Main Task
The endpoint restocking_shipment_controller#new should take as input a POST request with a payload of the following form:
`{
    "estimated_arrival_date": "2020-07-01",
    "tracking_code": "YY",
    "shipper": {
        "shipment_provider_id": 1
     },   
    "skus": [
        {"id": 1, "quantity": 2}
    ],
    "shipping_cost": 2
}`

And create the corresponding Restocking Shipment and Restocking Shipment Items. It should then return a JSON object containing the data for the newly created restocking shipment and restocking shipment items. 

Please also add tests in RSpec for the things you implement - we really care about good testing practices, so make sure to invest enough time here!

# Bonus
1. Add authentication in the `authenticate_request!` function, which is currently just a stub

If you have any questions about the scope of the project or details of the business goals, don't hesitate to contact us (leo.vonkleist@hive-logistics.com, lk@hive-logistics.com) with questions while you solve the exercise. Also feel free to use a different database than SQLite if you prefer. Happy coding!


