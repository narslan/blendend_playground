var r={fonts:[],filter:"",selectedFontId:null,selectedStyle:null,sampleText:"Hamburgefonts . 0123",fontSize:48,previewImage:"",error:"",previewTimeout:null,previewRequestId:0},e={};function c(){e.root=document.getElementById("fonts-root"),e.root&&(e.root.innerHTML=m(),y(),w(),g(),h())}function m(){return`
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

            <div class="font-preview-variations">
              <label class="control">
                <span>Variation</span>
                <select data-role="variation-select"></select>
              </label>
            </div>

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
  `}function y(){let t=e.root;e.fontList=t.querySelector('[data-role="font-list"]'),e.fontCount=t.querySelector('[data-role="font-count"]'),e.filterInput=t.querySelector('[data-role="filter-input"]'),e.sampleInput=t.querySelector('[data-role="sample-input"]'),e.sizeInput=t.querySelector('[data-role="size-input"]'),e.variationSelect=t.querySelector('[data-role="variation-select"]'),e.previewImg=t.querySelector('[data-role="preview-img"]'),e.previewPlaceholder=t.querySelector('[data-role="preview-placeholder"]'),e.previewMeta=t.querySelector('[data-role="preview-meta"]'),e.errorBox=t.querySelector('[data-role="font-error"]')}function w(){e.filterInput.addEventListener("input",t=>{r.filter=t.target.value.toLowerCase(),s()}),e.sampleInput.addEventListener("input",t=>{r.sampleText=t.target.value,f()}),e.sizeInput.addEventListener("input",t=>{r.fontSize=Number(t.target.value)||48,f()}),e.variationSelect&&e.variationSelect.addEventListener("change",t=>{r.selectedStyle=t.target.value||null;let i=r.fonts.find(n=>n.id===r.selectedFontId);i&&(v(i),u(i),d())})}function g(){e.sampleInput&&(e.sampleInput.value=r.sampleText),e.sizeInput&&(e.sizeInput.value=r.fontSize)}async function h(){try{let i=await(await fetch("/fonts/list")).json();i.ok&&(r.fonts=i.fonts||[],s())}catch(t){console.error("Failed to load fonts",t)}}function s(){if(!e.fontList)return;let t=r.filter||"",i=t.length===0?r.fonts:r.fonts.filter(n=>n.family.toLowerCase().includes(t));e.fontList.innerHTML="",e.fontCount.textContent=`${i.length}`,i.forEach(n=>{let a=document.createElement("button");a.className="font-card",a.type="button",a.dataset.fontId=n.id,a.innerHTML=`<div class="font-card__title">${n.family}</div>`,n.id===r.selectedFontId&&a.classList.add("font-card--active"),a.addEventListener("click",()=>p(n)),e.fontList.appendChild(a)}),!r.selectedFontId&&i.length>0&&p(i[0])}function p(t){t&&(r.selectedFontId=t.id,r.selectedStyle=t.variations?.[0]?.style||null,r.previewImage="",r.error="",s(),v(t),u(t),d())}function v(t){if(!e.variationSelect)return;e.variationSelect.innerHTML="";let i=t.variations||[];if(i.forEach(n=>{let a=document.createElement("option");a.value=n.style,a.textContent=`${n.style} \xB7 ${n.weight}`,a.selected=n.style===r.selectedStyle,e.variationSelect.appendChild(a)}),i.length===0){let n=document.createElement("option");n.textContent="No variations found",n.value="",e.variationSelect.appendChild(n)}e.variationSelect.disabled=i.length===0}function u(t){if(!e.previewMeta)return;let i=t.variations.find(n=>n.style===r.selectedStyle)||t.variations[0];if(!i){e.previewMeta.textContent="";return}e.previewMeta.innerHTML=`
    <div><strong>Family:</strong> ${t.family}</div>
    <div><strong>Style:</strong> ${i.style} (${i.weight})</div>
    <div><strong>Path:</strong> ${i.path}</div>
  `}function o(t){!e.previewImg||!e.previewPlaceholder||(e.previewImg.style.display=t?"block":"none",e.previewPlaceholder.style.display=t?"none":"flex",e.previewPlaceholder.textContent=t?"":r.selectedFontId?"Rendering preview\u2026":"Select a font to see its preview.")}function l(){e.errorBox&&(r.error?(e.errorBox.style.display="block",e.errorBox.textContent=r.error):(e.errorBox.style.display="none",e.errorBox.textContent=""))}async function d(){if(!r.selectedFontId){r.previewImage="",o(!1);return}let t=++r.previewRequestId;o(!1),l();try{let n=await(await fetch("/fonts/preview",{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify({font_id:r.selectedFontId,style:r.selectedStyle,text:r.sampleText,size:r.fontSize})})).json();if(t!==r.previewRequestId)return;n.ok?(r.previewImage=n.image,r.error="",e.previewImg&&(e.previewImg.src=n.image),o(!0),l()):(r.previewImage="",r.error=n.error||"Preview failed",o(!1),l())}catch(i){if(t!==r.previewRequestId)return;r.previewImage="",r.error=String(i),o(!1),l()}}function f(){r.previewTimeout&&(clearTimeout(r.previewTimeout),r.previewTimeout=null),r.previewTimeout=setTimeout(()=>d(),200)}document.readyState==="loading"?document.addEventListener("DOMContentLoaded",c):c();
