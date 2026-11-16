# ECHOES OF ASTRA — GAME GUIDE & DOKUMENTASI PROYEK

**Echoes of Astra** adalah game petualangan naratif 2D *Anime Fantasy* yang dikembangkan menggunakan **Godot 4.x**. Game ini mengusung fokus pada atmosfer dunia, eksplorasi narasi, dialog pilihan, penyelesaian puzzle mekanisme, serta sistem multi-ending berdasarkan akumulasi **Memory Points**.

---

## 🎮 Kontrol Permainan (Top-Down RPG)

| Aksi | Tombol Keyboard |
|---|---|
| **Bergerak Atas** | `W` atau `Panah Atas` |
| **Bergerak Bawah** | `S` atau `Panah Bawah` |
| **Bergerak Kiri** | `A` atau `Panah Kiri` |
| **Bergerak Kanan** | `D` atau `Panah Kanan` |
| **Periksa / Interaksi / Bicara** | `E` |
| **Lanjutkan Dialog / Teks** | `E`, `Spasi`, `Enter`, atau `Klik Kiri Mouse` |
| **Pilih Keputusan & Selesaikan Puzzle** | `Klik Kiri Mouse` pada tombol UI |

---

## 📁 Struktur Direktori Proyek

```
game MPP/
├── project.godot               # Konfigurasi Godot 4 & Autoload
├── prefabs/                    # Objek siap pakai (Prefab)
│   ├── player.tscn             # Karakter utama (Aren) + Camera2D + Detector
│   ├── interactable.tscn       # Node universal untuk trigger objek & NPC
│   └── ui/                     # Komponen UI terisolasi
│       ├── dialogue_box.tscn   # Kotak dialog bergaya anime + pilihan pemain
│       ├── hud.tscn            # Indikator Memory Point & pelacak objektif
│       ├── memory_cutscene.tscn# Vignette kilas balik ingatan
│       ├── crystal_puzzle_ui.tscn # Mini-game mekanisme resonansi kristal
│       ├── diary_puzzle_ui.tscn   # Mini-game penyusunan buku harian Lyra
│       └── temple_puzzle_ui.tscn  # Mini-game piringan konstelasi kuil
├── scenes/                     # Alur cerita utama
│   ├── title_screen.tscn       # Menu utama (Mulai Baru, Lanjutkan, Kontrol)
│   ├── ch0_prologue.tscn       # Bab 1: Hutan Misterius & Desa Astra
│   ├── quests/
│   │   ├── ch1_quest1_cave.tscn    # Bab 2: Gua Kristal & Pertemuan Pertama
│   │   ├── ch2_quest2_village.tscn # Bab 3: Desa yang Terlupakan & Janji
│   │   └── ch3_quest3_temple.tscn  # Bab 4: Kuil Astra & Silent Eclipse
│   └── endings/
│       ├── ending_good.tscn    # Good Ending: The Promise Reunited (3 Poin)
│       └── ending_bad.tscn     # Bad Ending: The Eternal Silence (0-2 Poin)
└── scripts/                    # Seluruh logika permainan (GDScript)
    ├── core/
    │   ├── game_manager.gd     # Autoload GameManager (State, Ending, Save/Load)
    │   ├── dialogue_manager.gd # Autoload DialogueManager (Typewriter & Choices)
    │   ├── quest_manager.gd    # Autoload QuestManager (Objectives & Signals)
    │   └── sound_manager.gd    # Autoload SoundManager (Sintesis audio prosedural lonceng, kristal, dialog)
    ├── entities/
    │   ├── player.gd           # Pengendali karakter Aren 2D
    │   ├── interactable.gd     # Script trigger dan visualisasi procedural
    │   └── environment_2d.gd   # Render latar belakang dinamis tiap bioma
    ├── puzzles/                # Logika ketiga puzzle quest
    └── ui/                     # Script antarmuka pengguna
```

---

## 🌟 Ringkasan Alur Cerita & Sistem Poin Ingatan

### 1. Bab 1 — Prologue: The Lost Memory
- Aren terbangun di Hutan Misterius di dekat pohon tua.
- Memeriksa kristal biru yang memancarkan suara lonceng dan memperlihatkan bayangan Lyra.
- Berjalan ke kanan menuju Desa Astra dan bertemu **Penjaga Arsip Eldrin**.
- Eldrin membuka jalan menuju 3 lokasi ingatan masa lalu Aren.

### 2. Bab 2 — Quest 1: The Forgotten Cave
- **Tema:** Pertemuan Pertama (Ingatan tentang Lyra).
- Kumpulkan 3 fragmen kristal yang tersebar di dalam gua.
- Pecahkan puzzle mekanisme kristal kuno untuk membuka pintu segel.
- Saksikan kilas balik masa kecil Aren dan Lyra.
- **Pilihan 1:**
  - `A`: Menyimpan pesan Lyra $\rightarrow$ **+1 Memory Point**
  - `B`: Mengabaikan pesan $\rightarrow$ **+0 Memory Point**

### 3. Bab 3 — Quest 2: The Forgotten Promise
- **Tema:** Janji yang Terlupakan.
- Jelajahi reruntuhan desa tua dan temukan 3 lembar halaman buku harian.
- Susun halaman buku harian sesuai urutan kronologis untuk membuka ruang rahasia.
- Saksikan kilas balik janji Aren dan Lyra di atas bukit saat langit menggelap.
- **Pilihan 2:**
  - `A`: Membaca seluruh isi surat dan memahami pesan Lyra $\rightarrow$ **+1 Memory Point**
  - `B`: Mengambil surat tanpa membaca dan langsung pergi $\rightarrow$ **+0 Memory Point**

### 4. Bab 4 — Quest 3: The Truth of Silent Eclipse
- **Tema:** Kebenaran di Balik Masa Lalu.
- Masuki reruntuhan Kuil Astra dan hadapi **The Hollow Knight**.
- Selaraskan ketiga piringan konstelasi kuil (Surya, Gerhana, Rembulan) menuju Zenith (180°).
- Sentuh Kristal Utama untuk menyaksikan peristiwa *Silent Eclipse*.
- **Pilihan 3 (Final Choice):**
  - `A`: Mengalirkan kekuatan kristal dengan hati-hati $\rightarrow$ **+1 Memory Point**
  - `B`: Memaksakan kekuatan kristal secepat mungkin $\rightarrow$ **+0 Memory Point**

---

## 🏆 Penentuan Ending

Game mengevaluasi total **Memory Point** yang diperoleh pemain (0–3 poin):

* **Total 3 Poin $\rightarrow$ GOOD ENDING: "THE PROMISE REUNITED"**
  Aren menyatukan ketiga fragmen ingatan dengan sempurna, memahami seluruh pesan Lyra, dan membebaskannya dari kurungan Kristal Utama. Keduanya bersatu kembali menyambut fajar baru di dunia Astra.
  > *"Some memories are lost, but never truly disappear."*

* **Total 0–2 Poin $\rightarrow$ BAD ENDING: "THE ETERNAL SILENCE"**
  Aren memaksakan resonansi kristal tanpa pemahaman utuh. Kristal utama retak dan kehilangan cahayanya, suara Lyra memudar, dan Aren kembali sendirian di dalam kuil sunyi.
  > *"Even when memories return, not everything can be recovered."*

---

## 🚀 Cara Menjalankan Game

1. **Menggunakan Godot Editor:**
   - Buka Godot Engine 4.x.
   - Pilih **Import** lalu arahkan ke folder `game MPP` yang berisi file `project.godot`.
   - Tekan tombol **Play Project** (`F5`) di pojok kanan atas editor.

2. **Menjalankan Langsung via Command Line:**
   ```bash
   "C:\Users\TEFA RPL\Downloads\kvin\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --path "c:\Users\TEFA RPL\Downloads\kvin\game MPP"
   ```

