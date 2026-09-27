"""Deploy the load procedures, refresh Bronze and Silver, and create the Gold views."""

import subprocess
from pathlib import Path

SERVER = r".\SQLEXPRESS"
DATABASE = "telco_dwh"
ROOT = Path(__file__).resolve().parent
data_path = str(ROOT / "data").replace("'", "''")

steps = [
    ("Deploying Bronze procedure", "-i", str(ROOT / "scripts/bronze/proc_load_bronze.sql")),
    ("Deploying Silver procedure", "-i", str(ROOT / "scripts/silver/proc_load_silver.sql")),
    ("Loading Bronze", "-Q", f"EXEC bronze.load_bronze @data_directory = N'{data_path}';"),
    ("Loading Silver", "-Q", "EXEC silver.load_silver;"),
    ("Creating Gold views", "-i", str(ROOT / "scripts/gold/create_gold_views.sql")),
]

for description, option, value in steps:
    print(f"{description}...", flush=True)
    subprocess.run(
        [
            "sqlcmd",
            "-S", SERVER,
            "-d", DATABASE,
            "-E",
            "-C",
            "-b",
            "-x",
            "-l", "15",
            option, value,
        ],
        check=True,
    )

print("Finished. Bronze and Silver are refreshed, and the Gold views are ready.")
