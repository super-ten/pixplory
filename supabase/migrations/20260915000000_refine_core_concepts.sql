begin;
do $$
begin
  if exists (select 1 from public.categories where id = '087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid) then
    update public.categories set title='1. 核心技術概念 (Core Concepts)' where id='087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid;
    insert into public.entries (id,category_id,term,intl,cn,description,sort_order) values
    ('3dfd78b2-058f-4cdd-a652-5de60022f50d'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'LLM','Large Language Model','大語言模型','以大規模文本與多模態資料訓練的生成式模型，根據上下文預測後續 Token。擅長語言理解、生成與推理，但輸出仍可能出錯，需配合檢索、工具與評測使用。',0),
    ('0f1e984c-5eb2-4205-8380-6b253b92238c'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Agent','AI Agent','智能體','以模型為決策核心，能感知上下文、規劃步驟、調用工具並根據結果繼續行動的軟件系統。Agent 不等於模型本身，其可靠性取決於權限、工具、記憶、評測與人工監督。',1),
    ('f22a9531-a1bb-4a67-aef2-65fbec0f0566'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Skills','Agent Skills / Toolsets','技能 / 工具集','可重用的任務能力包，通常包含操作指引、工具、腳本、範本與領域知識，例如檢索資料、處理文檔或調用渲染器。Skill 規範 Agent 如何完成一類工作，而非單純等同於工具。',2),
    ('2d34aa4e-83c5-49d1-92e9-0b0e7c7bba73'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'MCP','Model Context Protocol','模型上下文協議','一種開放協議，用標準方式讓 AI 應用連接工具、資料來源與可重用提示。它降低整合成本，但不自動保證安全或合規；權限、驗證、資料邊界與審計仍需由實作方負責。',3),
    ('b582371c-583b-42bd-b6e0-26e9fde0980b'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'CLI','Command Line Interface','命令行界面','以文字命令與程式互動的介面，便於自動化、批次處理與組合工具。CLI 型 Agent 只擁有使用者或沙箱授予的權限，不應預設為最高權限。',4),
    ('c2fadd12-b417-4e4a-a002-b73e1764cb38'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'RAG','Retrieval-Augmented Generation','檢索增強生成','在生成前檢索外部資料，並把相關片段加入模型上下文，以提升時效性、可追溯性與領域覆蓋。RAG 能降低部分事實錯誤，但效果仍取決於資料品質、檢索、排序與引用驗證。',5),
    ('0bd79829-5a7c-4b6d-8e0e-d68926cb1d93'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Vibe Coding','Vibe Coding','氛圍編程 / 意圖驅動編程','以自然語言描述意圖並快速接受、試用 AI 生成代碼的開發方式，重視迭代速度與結果體驗。適合原型探索；進入生產環境仍需理解代碼、測試、安全審查與版本控制。',6),
    ('c6679b22-a777-4127-9d22-b000e2099b55'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Markdown','Markdown','純文本標記語言','用簡潔符號為純文字添加標題、列表、連結與程式碼等結構的輕量標記語言，常用於 README、文檔、提示與 Agent 指令文件。不同解析器支持的擴展語法可能不同。',7),
    ('216ae8f6-6557-4a67-b78f-ab612862cf77'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'IDE','Integrated Development Environment','整合開發環境','把程式編輯、執行、除錯、測試、版本控制與專案管理整合在同一工作環境中的軟件。AI-first IDE 會在此基礎上加入程式理解、生成與 Agent 工作流。',8),
    ('4e1d96f3-9b0f-4ed8-b091-dbde51bf6cbf'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Workflow','Workflow','工作流','將任務拆成可追蹤的步驟、依賴、路由與規則，使人、模型和工具按條件協作。工作流可以是固定流程，也可以包含由 Agent 動態決策的分支。',9),
    ('4b26e1f7-ec18-43b5-a05d-bb1e761f70dc'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Git','Git','分散式版本控制系統','分散式版本控制系統，用提交記錄追蹤文件變更，並以分支、合併與回退支持多人協作。可類比為帶完整差異與歷史的專案存檔系統。',10),
    ('a7de793f-223b-4e79-bb51-9cb7088120e6'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Task','Task','任務','具有明確目標、輸入、約束與完成標準的工作單元，可由人、模型或 Agent 執行。任務列表只是管理多個 Task 的一種介面。',11),
    ('4fe30833-6799-4392-8d9a-a1c868a0c321'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'PRD','Product Requirements Document','產品需求文檔','描述產品目標、使用者、需求範圍、流程、約束與驗收標準的文件。AI 產品的 PRD 還應明確模型邊界、資料需求、評測指標、安全風險與人工兜底。',12),
    ('8f53f8ce-e5dc-488b-a3ab-b08429383136'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'React','React','React 前端函式庫','用元件與狀態模型構建 Web 使用者介面的 JavaScript 函式庫。React 本身不會直接生成 iOS 或 Android 原生應用；跨平台原生開發通常使用相關但獨立的 React Native。',13),
    ('4d226b26-7964-4450-902d-8598ccaed5db'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Canvas','Canvas / Visual Workspace','視覺畫布 / 可視化工作區','以自由佈局方式組織文字、圖像、節點與連線的工作介面，適合構思、改稿和呈現關係。它是互動形態，不等同於 HTML Canvas API，也不必然包含 AI。',14),
    ('9d0fede8-0087-4504-a0a3-e79b4e288ed5'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'FDE','Forward Deployed Engineer','前線部署工程師 / 駐場交付工程師','深入客戶現場，把通用技術產品配置、整合並迭代為可用業務方案的工程角色。核心能力涵蓋軟件工程、領域洞察、需求拆解、客戶溝通與交付閉環，並不限於 AI。',15),
    ('11111111-1111-4111-8111-111111111111'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Transformer','Transformer Architecture','Transformer 架構','以注意力機制為核心的神經網絡架構，可並行處理序列並學習長距離關係，是多數現代大語言模型與多模態模型的基礎。',16),
    ('22222222-2222-4222-8222-222222222222'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Token','Token','詞元 / 標記','模型讀取與生成內容的基本計算單位，可能是一個字、詞的一部分、符號或其他資料片段。Token 數量會影響上下文容量、延遲與使用成本。',17),
    ('33333333-3333-4333-8333-333333333333'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Context Window','Context Window','上下文窗口','模型在一次請求中可共同參考的輸入與輸出 Token 範圍。窗口更大不代表模型能同等準確地使用其中所有信息，仍需良好的結構、檢索與摘要策略。',18),
    ('44444444-4444-4444-8444-444444444444'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Prompt','Prompt / Instruction','提示 / 指令','提供給模型的任務說明、上下文、約束與輸出要求。高品質提示通常明確目標、資料邊界和驗收標準，但不能取代工具權限、程式驗證與系統設計。',19),
    ('55555555-5555-4555-8555-555555555555'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Embedding','Embedding / Vector Representation','嵌入向量 / 向量表徵','把文字、圖像或其他資料映射為數值向量，使語義相近的內容在向量空間中更接近。常用於語義搜尋、聚類、推薦與 RAG 檢索。',20),
    ('66666666-6666-4666-8666-666666666666'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Tool Calling','Tool Calling / Function Calling','工具調用 / 函數調用','模型按預定義結構選擇工具並產生參數，由應用實際執行，再把結果返回模型。它讓模型能查資料或採取行動，但必須配合參數驗證、權限控制與確認機制。',21),
    ('77777777-7777-4777-8777-777777777777'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Inference','Model Inference','模型推理 / 推論','使用已訓練模型對新輸入產生預測或內容的運行階段。推理品質、速度與成本會受模型、硬件、上下文長度、取樣參數及快取策略影響。',22),
    ('88888888-8888-4888-8888-888888888888'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Fine-tuning','Fine-tuning / Post-training','微調 / 後訓練','在基礎模型之上使用特定資料或偏好訊號繼續訓練，以調整行為、風格或任務能力。它適合穩定改變模型行為；需要即時外部知識時通常優先考慮 RAG。',23),
    ('99999999-9999-4999-8999-999999999999'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Hallucination','Model Hallucination','模型幻覺','模型生成看似合理但缺乏依據、與來源矛盾或事實錯誤的內容。可透過檢索、引用、工具查證、結構化輸出、評測與人工覆核降低風險，但難以完全消除。',24),
    ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Multimodality','Multimodality','多模態','模型理解或生成文字、圖像、音訊、影片等多種資料形態的能力。多模態系統需要處理不同模態的對齊、時序、解析度、版權與隱私問題。',25),
    ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Evals','Evaluations / Evals','模型與系統評測','用可重複的資料集、指標與人工標準衡量模型或 Agent 的品質、可靠性、安全性、延遲與成本。評測應覆蓋真實任務、邊界案例及版本回歸。',26),
    ('cccccccc-cccc-4ccc-8ccc-cccccccccccc'::uuid,'087cde3a-f15f-4186-ac5d-23c5d9ae8ba5'::uuid,'Guardrails','AI Guardrails','安全護欄 / 行為約束','在模型前後與工具執行層設置的政策、權限、輸入輸出檢查、人工確認和監控機制，用於降低越權、資料洩漏、不安全內容與錯誤操作風險。',27)
    on conflict (id) do update set term=excluded.term,intl=excluded.intl,cn=excluded.cn,description=excluded.description,sort_order=excluded.sort_order,deleted_at=null;
  end if;
end
$$;
commit;
