// État global du plugin
let installedApps = [];
let createdMenus = [];
let currentEditingMenuId = null;

// Éléments du DOM
const menusWrapper = document.getElementById('menus-wrapper');
const btnMainAdd = document.getElementById('btn-main-add');
const modal = document.getElementById('modal-select');
const menuNameInput = document.getElementById('menu-name-input');
const appsListContainer = document.getElementById('apps-list-container');
const btnCancel = document.getElementById('btn-cancel');
const btnSave = document.getElementById('btn-save');

// Initialisation
document.addEventListener('DOMContentLoaded', async () => {
  await loadInstalledApps();
  setupEventListeners();
  renderMenus();
});

// Récupération des applications via l'API Omarchy / Système
async function loadInstalledApps() {
  if (window.Omarchy && window.Omarchy.system) {
    installedApps = await window.Omarchy.system.getApps();
  } else {
    // Fallback de test si l'API n'est pas encore instanciée dans l'environnement dev
    installedApps = [
      { id: '1', name: 'Terminal', exec: 'x-terminal-emulator' },
      { id: '2', name: 'Navigateur Web', exec: 'firefox' },
      { id: '3', name: 'Gestionnaire de fichiers', exec: 'thunar' },
      { id: '4', name: 'Éditeur de texte', exec: 'gedit' }
    ];
  }
}

function setupEventListeners() {
  btnMainAdd.addEventListener('click', () => openModal());
  btnCancel.addEventListener('click', closeModal);
  btnSave.addEventListener('click', saveMenu);
}

function openModal(menuId = null) {
  currentEditingMenuId = menuId;
  appsListContainer.innerHTML = '';
  
  const existingMenu = createdMenus.find(m => m.id === menuId);
  menuNameInput.value = existingMenu ? existingMenu.name : '';

  installedApps.forEach(app => {
    const isChecked = existingMenu ? existingMenu.apps.some(a => a.id === app.id) : false;
    
    const row = document.createElement('label');
    row.className = 'app-item';
    row.innerHTML = `
      <input type="checkbox" value="${app.id}" ${isChecked ? 'checked' : ''}>
      <span>${app.name}</span>
    `;
    appsListContainer.appendChild(row);
  });

  modal.classList.remove('hidden');
}

function closeModal() {
  modal.classList.add('hidden');
  currentEditingMenuId = null;
}

function saveMenu() {
  const name = menuNameInput.value.trim() || 'Menu';
  const checkedBoxes = appsListContainer.querySelectorAll('input[type="checkbox"]:checked');
  
  const selectedAppIds = Array.from(checkedBoxes).map(cb => cb.value);
  const selectedApps = installedApps.filter(app => selectedAppIds.includes(app.id));

  if (currentEditingMenuId) {
    const menu = createdMenus.find(m => m.id === currentEditingMenuId);
    if (menu) {
      menu.name = name;
      menu.apps = selectedApps;
    }
  } else {
    createdMenus.push({
      id: Date.now().toString(),
      name: name,
      apps: selectedApps
    });
  }

  closeModal();
  renderMenus();
}

function renderMenus() {
  menusWrapper.innerHTML = '';

  createdMenus.forEach(menu => {
    const container = document.createElement('div');
    container.className = 'menu-dropdown-container';

    // Sélecteur déroulant
    const select = document.createElement('select');
    select.className = 'app-select';
    
    const defaultOption = document.createElement('option');
    defaultOption.textContent = menu.name;
    defaultOption.disabled = true;
    defaultOption.selected = true;
    select.appendChild(defaultOption);

    menu.apps.forEach(app => {
      const opt = document.createElement('option');
      opt.value = app.exec;
      opt.textContent = app.name;
      select.appendChild(opt);
    });

    select.addEventListener('change', (e) => {
      const execPath = e.target.value;
      if (execPath) {
        launchApp(execPath);
        select.value = menu.name; // Réinitialiser le label du menu
      }
    });

    // Bouton + à côté du nom pour ajouter/modifier des éléments à CE menu
    const btnAddApp = document.createElement('button');
    btnAddApp.className = 'btn-icon';
    btnAddApp.textContent = '+';
    btnAddApp.title = 'Ajouter/Modifier des applications dans ce menu';
    btnAddApp.addEventListener('click', () => openModal(menu.id));

    container.appendChild(select);
    container.appendChild(btnAddApp);
    menusWrapper.appendChild(container);
  });
}

function launchApp(execPath) {
  if (window.Omarchy && window.Omarchy.system) {
    window.Omarchy.system.launch(execPath);
  } else {
    console.log(`[Dev] Lancement de l'application : ${execPath}`);
  }
}