# EECS 449 Warm-Up Assignment
Clay VanOphem

# Submission
## Part 1
Implemented two walkers: 
- add_two_nums
Adds two numbers together
![Image of Walker Code](/img/walker_two.jpg?raw=true "Code")
- stock_price_checker
Returns mock stock price data
![Image of Walker Code](/img/walker_stock.jpg?raw=true "Code")

![Swagger](/img/449-new-walkers-swagger.jpg)

## Part 2
Docs I added were Luis Pessoa's "The Entangled Brain" as a PDF, and Michael Wooldridge's "A Brief History of Artificial Intelligence". I elected not to upload the PDFs to this public repository, though ;)
- ![Image of Docs folder](/img/RAG-docs.png)
Two LLMs I chose:
- OpenAI GPT-4o Mini
    - ![Image of 4o Mini output](/img/RAG-4o-mini.jpg)
- Llama 3.1 (8B)
    - ![Image of Llama 3.1 output](/img/RAG-Llama3-1.jpg)

## Part 3
New state: FAChat for 'Financial Advice'
Added ChatType.FA
Added ChatType.QA to the Router for when context is related to personal finance or real estate

![Image of new chattype](/img/449-FAChat-code.jpg)
![Image of new chat in classifier](/img/449-Chat-Classifier-Code.jpg)
![Image testing the new chat](/img/449-FA_chat.jpg)