function u(c){return fetch("/swatches/render",{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify(c)}).then(e=>e.json()).then(({image:e})=>e).catch(e=>(console.error(e),null))}var r=document.getElementById("swatches-root");function h(){if(!r)return;r.innerHTML=`
    <div class="sw-controls">
      <div class="sw-field">
        <label>Source</label>
        <select id="sw-source"></select>
      </div>
      <div class="sw-field">
        <label>Palette</label>
        <select id="sw-scheme"></select>
      </div>
    </div>
    <div class="sw-output">
      <img id="sw-preview" />
    </div>
  `;let c=document.getElementById("sw-preview"),e=document.getElementById("sw-source"),t=document.getElementById("sw-scheme");fetch("/swatches/palettes").then(n=>n.json()).then(({sources:n=[],palettes:o={}})=>{!n||n.length===0||(n.forEach(s=>{let l=document.createElement("option");l.value=s,l.textContent=s,e.appendChild(l)}),e.onchange=()=>{i(o,e.value,t,c),a(c,t.value,e.value)},i(o,n[0],t,c),a(c,t.value,e.value))}).catch(n=>console.error(n))}function i(c,e,t,n){t.innerHTML="";let o=c[e]||[];o.forEach(s=>{let l=document.createElement("option");l.value=s,l.textContent=s,t.appendChild(l)}),o.length>0&&(t.value=o[0],t.onchange=()=>a(n,t.value,e))}function a(c,e,t){if(!e)return;let n=t?`?source=${encodeURIComponent(t)}`:"";fetch(`/swatches/palette/${encodeURIComponent(e)}${n}`).then(o=>o.json()).then(({values:o,colors:s,name:l,source:d})=>{v(c,l,d||t)}).catch(o=>console.error(o))}function v(c,e,t){let n=document.getElementById("sw-scheme"),o=e||n&&n.value;o&&u({name:o,source:t}).then(s=>{s&&(c.src=s)})}h();
