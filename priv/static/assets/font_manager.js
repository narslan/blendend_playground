var r={fonts:[],filter:"",selectedFontId:null,selectedStyle:null,sampleText:"Aa Bb Cc \xB7 The quick brown fox jumps over the lazy dog",fontSize:48,previewImage:"",error:"",previewTimeout:null,previewRequestId:0},e={};function c(){e.root=document.getElementById("fonts-root"),e.root&&(e.root.innerHTML=m(),y(),w(),h(),g())}function m(){return`
    <div class="font-manager">
      <header class="font-manager__header">
        <div>
          <h1>Font Manager</h1>
          <p>Lookup scanned fonts, find their file paths, and render a quick preview.</p>
        </div>
        <div class="font-manager__filters">
          <label class="sr-only" for="font-filter">Filter fonts</label>
          <input id="font-filter" type="text" placeholder="Filter by family" data-role="filter-input" />
        </div>
      </header>

      <div class="font-manager__layout">
        <section class="font-manager__list">
          <div class="font-manager__list-header">
            <h2>Fonts</h2>
            <span class="font-manager__count" data-role="font-count">0</span>
          </div>
          <div class="font-card-list" data-role="font-list"></div>
        </section>

        <section class="font-manager__preview">
          <div class="font-preview-card">
            <div class="font-preview-controls">
              <label class="control">
                <span>Sample text</span>
                <input type="text" data-role="sample-input" />
              </label>
              <label class="control control--size">
                <span>Size</span>
                <input type="number" min="8" max="120" step="2" data-role="size-input" />
              </label>
            </div>

            <div class="font-preview-variations" data-role="variation-chips"></div>

            <div class="font-preview-output">
              <img data-role="preview-img" alt="font preview" style="display:none" />
              <div class="font-preview-placeholder" data-role="preview-placeholder">
                Select a font to see its preview.
              </div>
            </div>

            <div class="font-preview-meta" data-role="preview-meta"></div>
            <div class="error-message" data-role="font-error" style="display:none"></div>
          </div>
        </section>
      </div>
    </div>
  `}function y(){let t=e.root;e.fontList=t.querySelector('[data-role="font-list"]'),e.fontCount=t.querySelector('[data-role="font-count"]'),e.filterInput=t.querySelector('[data-role="filter-input"]'),e.sampleInput=t.querySelector('[data-role="sample-input"]'),e.sizeInput=t.querySelector('[data-role="size-input"]'),e.variationChips=t.querySelector('[data-role="variation-chips"]'),e.previewImg=t.querySelector('[data-role="preview-img"]'),e.previewPlaceholder=t.querySelector('[data-role="preview-placeholder"]'),e.previewMeta=t.querySelector('[data-role="preview-meta"]'),e.errorBox=t.querySelector('[data-role="font-error"]')}function w(){e.filterInput.addEventListener("input",t=>{r.filter=t.target.value.toLowerCase(),s()}),e.sampleInput.addEventListener("input",t=>{r.sampleText=t.target.value,v()}),e.sizeInput.addEventListener("input",t=>{r.fontSize=Number(t.target.value)||48,v()})}function h(){e.sampleInput&&(e.sampleInput.value=r.sampleText),e.sizeInput&&(e.sizeInput.value=r.fontSize)}async function g(){try{let n=await(await fetch("/fonts/list")).json();n.ok&&(r.fonts=n.fonts||[],s())}catch(t){console.error("Failed to load fonts",t)}}function s(){if(!e.fontList)return;let t=r.filter||"",n=t.length===0?r.fonts:r.fonts.filter(i=>i.family.toLowerCase().includes(t));e.fontList.innerHTML="",e.fontCount.textContent=`${n.length}`,n.forEach(i=>{let a=document.createElement("button");a.className="font-card",a.type="button",a.dataset.fontId=i.id,a.innerHTML=`
      <div class="font-card__title">${i.family}</div>
      <div class="font-card__meta">${i.variations.map(u=>u.style).join(", ")}</div>
      <div class="font-card__path">${i.variations[0]?.path||""}</div>
    `,i.id===r.selectedFontId&&a.classList.add("font-card--active"),a.addEventListener("click",()=>p(i)),e.fontList.appendChild(a)}),!r.selectedFontId&&n.length>0&&p(n[0])}function p(t){t&&(r.selectedFontId=t.id,r.selectedStyle=t.variations?.[0]?.style||null,r.previewImage="",r.error="",s(),f(t),I(t),d())}function f(t){e.variationChips&&(e.variationChips.innerHTML="",(t.variations||[]).forEach(n=>{let i=document.createElement("button");i.type="button",i.className="font-chip",i.textContent=`${n.style} \xB7 ${n.weight}`,n.style===r.selectedStyle&&i.classList.add("font-chip--active"),i.addEventListener("click",()=>{r.selectedStyle=n.style,f(t),d()}),e.variationChips.appendChild(i)}))}function I(t){if(!e.previewMeta)return;let n=t.variations.find(i=>i.style===r.selectedStyle)||t.variations[0];if(!n){e.previewMeta.textContent="";return}e.previewMeta.innerHTML=`
    <div><strong>Family:</strong> ${t.family}</div>
    <div><strong>Style:</strong> ${n.style} (${n.weight})</div>
    <div><strong>Path:</strong> ${n.path}</div>
  `}function o(t){!e.previewImg||!e.previewPlaceholder||(e.previewImg.style.display=t?"block":"none",e.previewPlaceholder.style.display=t?"none":"flex",e.previewPlaceholder.textContent=t?"":r.selectedFontId?"Rendering preview\u2026":"Select a font to see its preview.")}function l(){e.errorBox&&(r.error?(e.errorBox.style.display="block",e.errorBox.textContent=r.error):(e.errorBox.style.display="none",e.errorBox.textContent=""))}async function d(){if(!r.selectedFontId){r.previewImage="",o(!1);return}let t=++r.previewRequestId;o(!1),l();try{let i=await(await fetch("/fonts/preview",{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify({font_id:r.selectedFontId,style:r.selectedStyle,text:r.sampleText,size:r.fontSize})})).json();if(t!==r.previewRequestId)return;i.ok?(r.previewImage=i.image,r.error="",e.previewImg&&(e.previewImg.src=i.image),o(!0),l()):(r.previewImage="",r.error=i.error||"Preview failed",o(!1),l())}catch(n){if(t!==r.previewRequestId)return;r.previewImage="",r.error=String(n),o(!1),l()}}function v(){r.previewTimeout&&(clearTimeout(r.previewTimeout),r.previewTimeout=null),r.previewTimeout=setTimeout(()=>d(),200)}document.readyState==="loading"?document.addEventListener("DOMContentLoaded",c):c();
