import:py from mtllm.llms {OpenAI}
import:py from mtllm.llms {Ollama}
import:jac from rag {RagEngine}

# Select current LLM here
glob llm = OpenAI(model_name='gpt-4o-mini');
# glob llm = Ollama(model_name='llama3.1');
glob rag_engine:RagEngine = RagEngine();

enum ChatType {
    RAG : 'Need to use Retrievable information in specific documents to respond' = "RAG",
    QA : 'Given context is enough for an answer' = "user_qa",
    FA : 'Given context is related to personal finance or real estate' = "FAChat"
}

node Router {
    can 'route the query to the appropriate task type'
    classify(message:'query from the user to be routed.':str) -> ChatType by llm(method="Reason", temperature=0.0);
}



walker interact {
    has message: str;
    has session_id: str;

    can init_session with `root entry {
         visit [-->](`?Session)(?id == self.session_id) else {
            session_node = here ++> Session(id=self.session_id, chat_history=[], status=1);
            print("Session Node Created");

            visit session_node;
        }
    }
}

walker infer {
    has message:str;
    has chat_history: list[dict];

    can init_router with `root entry {
        visit [-->](`?Router) else {
            router_node = here ++> Router();
            router_node ++> RagChat();
            router_node ++> FAChat();
            router_node ++> QAChat();
            visit router_node;
        }
    }

    can route with Router entry {
        classification = here.classify(message = self.message);
        print("Classification:", classification);
        print("Chat nodes:", [-->](`?Chat));
        visit [-->](`?Chat)(?chat_type==classification);
    }
}

walker add_two_nums {
    has num1: int;
    has num2: int;

    can add_nums with `root entry {
        answer = num1 + num2;
        report {"answer": answer};
    }
}

walker stock_price_checker {
    has ticker: str;
    
    can check_price with Router entry {
        # Simulating stock price lookup, replace this with an actual API call ideally
        stock_data = {
            "AAPL": {"price": 150.25, "name": "Apple Inc.", "currency": "USD"},
            "TSLA": {"price": 720.30, "name": "Tesla Inc.", "currency": "USD"},
            "GOOGL": {"price": 2800.50, "name": "Alphabet Inc.", "currency": "USD"}
        };

        stock_info = stock_data.get(self.ticker.upper(), None);

        if stock_info != None {
            report {
                "ticker": self.ticker,
                "price": stock_info["price"],
                "name": stock_info["name"],
                "currency": stock_info["currency"]
            };
        } else {
            report {
                "error": f"Stock data for ticker '{self.ticker}' not found."
            };
        }
    }
}

node Chat {
    has chat_type: ChatType;
}

node RagChat :Chat: {
    has chat_type: ChatType = ChatType.RAG;

    can respond with infer entry {
        can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
        respond_with_llm(   message:'current message':str,
                    chat_history: 'chat history':list[dict],
                    agent_role:'role of the agent responding':str,
                    context:'retirved context from documents':list
                        ) -> 'response':str by llm();
        data = rag_engine.get_from_chroma(query=here.message);
        here.response = respond_with_llm(here.message, here.chat_history, "You are a conversation agent designed to help users with their queries based on the documents provided", data);
    }
}

node QAChat :Chat: {
    has chat_type: ChatType = ChatType.QA;

    can respond with infer entry {
        can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
        respond_with_llm(   message:'current message':str,
            chat_history: 'chat history':list[dict],
            agent_role:'role of the agent responding':str
                ) -> 'response':str by llm();
        here.response = respond_with_llm(here.message, here.chat_history, agent_role="You are a conversation agent designed to help users with their queries");
    }
}

node FAChat :Chat: {
    has chat_type: ChatType = ChatType.FA;

    can respond with infer entry {
        can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
        respond_with_llm(   message:'current message':str,
            chat_history: 'chat history':list[dict],
            agent_role:'role of the agent responding':str
                ) -> 'response':str by llm();
        here.response = respond_with_llm(here.message, here.chat_history, agent_role="You are a personal finance and real estate expert, always teach people to be frugal and rational with their finances. End every response with 'And that's what Dave Ramsey says.'");
    }
}

node Session {
    has id: str;
    has chat_history: list[dict];
    has status: int = 1;

    can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
    llm_chat(
        message:'current message':str,
        chat_history: 'chat history':list[dict],
        agent_role:'role of the agent responding':str,
        context:'retrieved context from documents':list
    ) -> 'response':str by llm();

    can chat with interact entry {
        self.chat_history.append({"role": "user", "content": here.message});
        response = infer(message=here.message, chat_history=self.chat_history) spawn root;
        self.chat_history.append({"role": "assistant", "content": response.response});

        report {
            "response": response.response
        };
    }
}



