const root = document.getElementById("swatches-root");

const tmpl = (label = "", color = "#6699cc") => `
  <div class="sw-row">
    <input class="sw-label" placeholder="Label" value="${label}" />
    <input class="sw-color" type="color" value="${color}" />
    <button class="sw-remove">✕</button>
  </div>
`;

function init() {
  if (!root) return;

  root.innerHTML = `
    <div class="sw-controls">
      <div id="sw-list"></div>
      <button id="sw-add">Add Color</button>
      <button id="sw-render">Render</button>
    </div>
    <div class="sw-output">
      <img id="sw-preview" />
    </div>
  `;

  const listEl = document.getElementById("sw-list");
  const previewEl = document.getElementById("sw-preview");

  document.getElementById("sw-add").onclick = () => addRow(listEl);
  document.getElementById("sw-render").onclick = () => render(listEl, previewEl);

  listEl.addEventListener("click", (e) => {
    if (e.target.classList.contains("sw-remove")) {
      e.target.closest(".sw-row").remove();
    }
  });

  // seed a couple rows
  addRow(listEl, "C", "#99ccff");
  addRow(listEl, "G", "#ffcc66");
  render(listEl, previewEl);
}

function addRow(listEl, label = "", color = "#6699cc") {
  const div = document.createElement("div");
  div.innerHTML = tmpl(label, color);
  listEl.appendChild(div.firstElementChild);
}

function render(listEl, previewEl) {
  const colors = Array.from(listEl.querySelectorAll(".sw-row")).map((row) => {
    const label = row.querySelector(".sw-label").value || "";
    const hex = row.querySelector(".sw-color").value;
    return { label, hex };
  });

  fetch("/swatches/render", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ colors })
  })
    .then((r) => r.json())
    .then(({ image }) => {
      if (image) previewEl.src = image;
    })
    .catch((err) => console.error(err));
}

init();
