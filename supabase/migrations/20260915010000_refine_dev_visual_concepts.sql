begin;
do $$
begin
  if exists (select 1 from public.categories where id = any(array['d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid])) then
    update public.categories set title='2. 生產力與開發 (Development & Coding Agents)' where id='d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid;
    insert into public.entries (id,category_id,term,intl,cn,description,sort_order) values
    ('d9dbecf6-9229-47fa-a8d7-ff970ab326aa'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'AI-native IDE','Cursor, Windsurf','Trae、Qoder、通義靈碼','把程式碼理解、對話、補全、跨文件修改、終端與 Agent 工作流整合進開發環境。其價值不只在生成代碼，更在於利用專案上下文完成可審查、可回退的多步變更。',0),
    ('08e55c56-2809-4254-b0af-e953503db363'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'CLI Coding Agent','Claude Code, Codex CLI, Gemini CLI','命令行編程智能體','在終端中讀取代碼庫、編輯文件、執行命令與測試的編程 Agent。它適合自動化和遠端環境，但能力受工作目錄、沙箱、網絡與授權策略約束，不應被視為無限制接管電腦。',1),
    ('6cb65e00-95df-4474-a06a-cd85fb657b53'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'Cloud Development Environment','GitHub Codespaces, Firebase Studio, Replit','雲端開發環境','在瀏覽器或遠端容器中提供代碼、終端、預覽與部署能力的開發環境。它降低本地配置成本並提升環境一致性，但需關注休眠、資源配額、網絡延遲、資料駐留與供應商鎖定。',2),
    ('4e66fdaf-de1f-4e26-a670-e169f75854bd'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'Open-source Coding Agent','OpenHands, Aider, Cline','開源編程智能體','源碼公開、可自託管或二次開發的編程 Agent。其優勢是可審計與可定制，但模型費用、沙箱隔離、憑證管理、依賴安全與維護仍由部署者承擔。',3),
    ('d2000001-0000-4000-8000-000000000001'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'Code Completion','Inline Code Completion','代碼補全','根據游標位置、鄰近代碼與專案上下文預測下一段代碼的輔助方式。它適合局部、低延遲編寫；跨文件規劃、執行與驗證則通常需要 Agent 模式。',4),
    ('d2000002-0000-4000-8000-000000000002'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'Repository Context','Codebase Indexing / Repository Context','代碼庫上下文 / 索引','透過搜尋、符號索引、語義檢索與依賴分析，向模型提供與任務相關的文件和結構。上下文品質往往比一次塞入整個代碼庫更重要。',5),
    ('d2000003-0000-4000-8000-000000000003'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'Agent Mode','Agentic Coding Workflow','智能體開發模式','讓 AI 圍繞目標循環進行理解、規劃、修改、執行、觀察與修正的工作模式。與一次性問答相比，它能完成更長任務，也更需要檢查點、停止條件與人工覆核。',6),
    ('d2000004-0000-4000-8000-000000000004'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'Sandbox & Permissions','Execution Sandbox / Permission Model','執行沙箱與權限模型','限制 Agent 可讀寫文件、運行命令、訪問網絡與調用外部服務的安全邊界。最小權限、操作前確認和可追溯審計是生產使用的核心保障。',7),
    ('d2000005-0000-4000-8000-000000000005'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'Human-in-the-loop','Human-in-the-loop Development','人在迴路 / 人工覆核','在需求澄清、方案選擇、高風險操作與合併發布等節點保留人工判斷。目標不是逐步干預，而是在最關鍵的位置建立可驗證的控制點。',8),
    ('d2000006-0000-4000-8000-000000000006'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'CI/CD','Continuous Integration / Continuous Delivery','持續整合 / 持續交付','透過自動化構建、測試、掃描和部署，使代碼變更能持續驗證與交付。Agent 生成代碼後仍應進入同一品質門禁，而不是繞過工程流程。',9),
    ('d2000007-0000-4000-8000-000000000007'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'Code Review','AI-assisted Code Review','代碼審查','檢查變更的正確性、可維護性、安全性與影響範圍。AI 可輔助定位風險和生成測試，但最終判斷應基於差異、運行證據與專案標準。',10),
    ('d2000008-0000-4000-8000-000000000008'::uuid,'d6436ea1-bdf6-4558-b938-20d20b9e63a9'::uuid,'Agent Observability','Agent Tracing / Observability','智能體可觀測性','記錄提示、工具調用、文件修改、測試結果、耗時與錯誤，以便重現和評估 Agent 行為。生產指標應同時關注任務成功率、回歸、成本與人工接管率。',11)
    on conflict (id) do update set term=excluded.term,intl=excluded.intl,cn=excluded.cn,description=excluded.description,sort_order=excluded.sort_order,deleted_at=null;
    
    update public.categories set title='3. 多模態視覺生成 (Multimodal Visual Generation)' where id='fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid;
    insert into public.entries (id,category_id,term,intl,cn,description,sort_order) values
    ('ad668fbd-6d7b-4746-b541-7af221b96edf'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'Diffusion Models','Diffusion-based Generative Models','擴散生成模型','學習逐步逆轉加噪過程，從隨機噪聲生成圖像或影片的模型家族。擴散描述的是生成方法，不能把 Midjourney、Stable Diffusion、可靈等不同產品直接視為同一底層架構。',0),
    ('a19772fa-bb46-4417-8678-954d24a111e6'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'Node-based Workflow','ComfyUI','LiblibAI 工作流','以節點和連線組合模型載入、條件控制、採樣、後處理與輸出的可視化工作流。它提升可重用性與可調試性，但不改變底層模型本身的能力與限制。',1),
    ('3cf8fbce-6a25-42c8-878d-170ba069dcf3'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'Video Generation','Sora, Veo, Runway','可靈、Vidu、即夢','由文字、圖像或影片條件生成新影片的模型與產品類別。常見系統把壓縮後的時空片段作為序列建模，但產品實作並不完全相同；核心難點包括時序一致性、運動合理性與可控性。',2),
    ('d3000001-0000-4000-8000-000000000001'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'Latent Diffusion','Latent Diffusion Model (LDM)','潛空間擴散模型','先用編碼器把圖像壓縮到潛空間，再在較低維表示上執行擴散生成，最後解碼為圖像。這能顯著降低高解析度生成的計算成本，但壓縮也可能損失細節。',3),
    ('d3000002-0000-4000-8000-000000000002'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'DiT','Diffusion Transformer','擴散 Transformer','以 Transformer 取代傳統 U-Net 作為擴散模型骨幹，對潛空間圖像或影片片段進行建模。其優勢是易於擴展算力與模型規模，已成為多類生成系統的重要架構。',4),
    ('d3000003-0000-4000-8000-000000000003'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'Flow Matching','Flow Matching / Rectified Flow','流匹配 / 校正流','學習把噪聲分佈沿連續路徑運輸到資料分佈的向量場方法，可用較少步數進行生成。它與擴散相關但並非同義，實際品質和速度取決於訓練與採樣設計。',5),
    ('d3000004-0000-4000-8000-000000000004'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'Text-to-Image','Text-to-Image Generation','文生圖','根據文字提示生成圖像的任務。效果受提示理解、訓練資料、構圖能力與解碼品質影響；涉及品牌、人物或商用素材時還需考慮版權、肖像權與來源標註。',6),
    ('d3000005-0000-4000-8000-000000000005'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'Image-to-Image','Image-conditioned Generation / Editing','圖生圖 / 圖像編輯','以參考圖像配合文字或其他條件生成新圖，用於風格轉換、局部修改、姿態保持和版本探索。輸出與原圖的一致程度取決於條件強度和模型編輯能力。',7),
    ('d3000006-0000-4000-8000-000000000006'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'Inpainting & Outpainting','Inpainting / Outpainting','局部重繪 / 畫面擴展','Inpainting 在遮罩區域內重建或替換內容；Outpainting 則向畫布外延伸場景。高品質結果需要兼顧邊界融合、光影、透視與主體一致性。',8),
    ('d3000007-0000-4000-8000-000000000007'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'ControlNet','ControlNet / Spatial Conditioning','空間條件控制','在預訓練文生圖模型上加入邊緣、深度、姿態、分割等空間條件，使構圖更可控。它提升約束能力，但不保證身份、材質或細節完全一致。',9),
    ('d3000008-0000-4000-8000-000000000008'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'LoRA','Low-Rank Adaptation','低秩適配','以少量可訓練參數適配大型模型的高效微調方法，常用於角色、風格或領域定制。LoRA 文件較小且易組合，但可能過擬合、產生概念串擾或放大資料偏差。',10),
    ('d3000009-0000-4000-8000-000000000009'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'Temporal Consistency','Temporal Consistency / Motion Coherence','時序一致性 / 運動連貫性','影片生成中角色身份、物體外觀、場景結構和運動在連續幀間保持穩定的程度。它是區分單幀品質與完整影片可用性的核心指標。',11),
    ('d3000010-0000-4000-8000-000000000010'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'Upscaling','Super-resolution / Upscaling','超解析度 / 放大','從低解析度輸入生成更高解析度結果的後處理任務。生成式放大器可補充紋理，但新增細節不一定真實，證據型圖像或科研資料應避免把推測細節當作原始信息。',12),
    ('d3000011-0000-4000-8000-000000000011'::uuid,'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,'3D Generation','Text-to-3D / Image-to-3D','文生 3D / 圖生 3D','由文字或圖像生成網格、點雲、神經表示、材質或多視圖資產。評估不只看單一渲染圖，還需檢查幾何拓撲、多視角一致性、材質與下游軟件兼容性。',13)
    on conflict (id) do update set term=excluded.term,intl=excluded.intl,cn=excluded.cn,description=excluded.description,sort_order=excluded.sort_order,deleted_at=null;
  end if;
end
$$;
commit;
