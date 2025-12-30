# flutter_box_calculator

Here's the link to the app: <https://forkliftdev.github.io/flutter_box_calculator/>

The Forklift Developer’s Percentage Helper
In my day job, we forklift drivers across all four shifts kept running into the same problem. When a production line needed ten thousand units and a pallet held thirty two thousand, it was way easier for us, alegedly, overworked material handlers to just drop off a full pallet and let the reconciling department deal with the overage. Not ideal, but realistic.

Management wanted us to tighten things up and issue materials within a small, defined percentage of what the job actually required. The catch was that they gave us zero tools to make that happen. No calculator, no helper app, nothing. We were expected to do the math ourselves.

Now, I am not the person who casually calculates percentages in my head. Every time I had to figure out how much overage was acceptable, I had to re-teach myself the math. It got old fast. There had to be a better way, but the IT department was not exactly racing to help.

So I made a spreadsheet.

It worked, but typing numbers into a spreadsheet on the fly is clunky. That pushed me to turn it into a little coding project. I wrote a Dart program to handle the calculations, which also taught me how the ceil() operator works. Then I took it a step further and built a Flutter app. I will be honest, I vibe coded the whole thing. I am The Forklift Developer, not The Forklift Coder. Still, the Flutter version is way more user-friendly than both the spreadsheet and the terminal-based Dart script. And since I am the one using it, being user-friendly matters.

I am proud of it. It works great. The UI is not going to win any beauty contests, the colors are not my favorite, and the layout is a little clunky because the text does not wrap. But it does the job.

One last thought. If IT had built something like this and put it on the company server, I could run it from the computer mounted on my forklift. I would not have to pull out my phone, which always leads to seeing a text or an important email and getting distracted. It would keep me on track. But hey, what can you do.
