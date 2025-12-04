var c=document.getElementById("swatches-root"),i=(e="",n="#6699cc")=>`
  <div class="sw-row">
    <input class="sw-label" placeholder="Label" value="${e}" />
    <input class="sw-color" type="color" value="${n}" />
    <button class="sw-remove">\u2715</button>
  </div>
`;function a(){if(!c)return;c.innerHTML=`
    <div class="sw-controls">
      <div id="sw-list"></div>
      <button id="sw-add">Add Color</button>
      <button id="sw-render">Render</button>
    </div>
    <div class="sw-output">
      <img id="sw-preview" />
    </div>
  `;let e=document.getElementById("sw-list"),n=document.getElementById("sw-preview");document.getElementById("sw-add").onclick=()=>s(e),document.getElementById("sw-render").onclick=()=>l(e,n),e.addEventListener("click",o=>{o.target.classList.contains("sw-remove")&&o.target.closest(".sw-row").remove()}),s(e,"C","#99ccff"),s(e,"G","#ffcc66"),l(e,n)}function s(e,n="",o="#6699cc"){let t=document.createElement("div");t.innerHTML=i(n,o),e.appendChild(t.firstElementChild)}function l(e,n){let o=Array.from(e.querySelectorAll(".sw-row")).map(t=>{let r=t.querySelector(".sw-label").value||"",d=t.querySelector(".sw-color").value;return{label:r,hex:d}});fetch("/swatches/render",{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify({colors:o})}).then(t=>t.json()).then(({image:t})=>{t&&(n.src=t)}).catch(t=>console.error(t))}a();
