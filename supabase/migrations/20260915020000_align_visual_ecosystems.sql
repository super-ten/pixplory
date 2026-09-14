begin;

update public.entries as entry
set intl = revised.intl,
    cn = revised.cn,
    updated_at = now(),
    revision = entry.revision + 1
from (values
  ('ad668fbd-6d7b-4746-b541-7af221b96edf'::uuid, 'Stable Diffusion、Midjourney、Adobe Firefly', '擴散生成模型；可靈、即夢、通義萬相'),
  ('a19772fa-bb46-4417-8678-954d24a111e6'::uuid, 'ComfyUI、InvokeAI', '節點式工作流；LiblibAI、吐司 TusiArt'),
  ('3cf8fbce-6a25-42c8-878d-170ba069dcf3'::uuid, 'Sora、Veo、Runway', '影片生成；可靈、Vidu、即夢'),
  ('d3000001-0000-4000-8000-000000000001'::uuid, 'Stable Diffusion、DreamStudio、ComfyUI', '潛空間擴散模型；LiblibAI、吐司 TusiArt'),
  ('d3000002-0000-4000-8000-000000000002'::uuid, 'Stable Diffusion 3、FLUX.1、Sora', '擴散 Transformer；可靈、通義萬相、騰訊混元'),
  ('d3000003-0000-4000-8000-000000000003'::uuid, 'FLUX.1、Stable Diffusion 3、ComfyUI', '流匹配 / 校正流；通義萬相、騰訊混元、LiblibAI'),
  ('d3000004-0000-4000-8000-000000000004'::uuid, 'Midjourney、Adobe Firefly、ChatGPT Images', '文生圖；即夢、通義萬相、文心一格'),
  ('d3000005-0000-4000-8000-000000000005'::uuid, 'Midjourney Editor、Adobe Firefly、Runway', '圖生圖 / 圖像編輯；可靈、即夢、通義萬相'),
  ('d3000006-0000-4000-8000-000000000006'::uuid, 'Midjourney Editor、Photoshop Generative Fill、Clipdrop', '局部重繪 / 畫面擴展；即夢、通義萬相、LiblibAI'),
  ('d3000007-0000-4000-8000-000000000007'::uuid, 'ComfyUI、Stable Diffusion WebUI、Hugging Face', '空間條件控制；LiblibAI、吐司 TusiArt'),
  ('d3000008-0000-4000-8000-000000000008'::uuid, 'Civitai、Hugging Face、ComfyUI', '低秩適配；LiblibAI、吐司 TusiArt'),
  ('d3000009-0000-4000-8000-000000000009'::uuid, 'Runway、Sora、Veo', '時序一致性 / 運動連貫性；可靈、Vidu、即夢'),
  ('d3000010-0000-4000-8000-000000000010'::uuid, 'Topaz Gigapixel、Adobe Photoshop、Clipdrop', '超解析度 / 放大；美圖雲修、騰訊 ARC、通義萬相'),
  ('d3000011-0000-4000-8000-000000000011'::uuid, 'Meshy、Luma AI、Spline', '文生 3D / 圖生 3D；騰訊混元 3D、Tripo AI、Rodin')
) as revised(id, intl, cn)
where entry.id = revised.id
  and entry.category_id = 'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid;

commit;
