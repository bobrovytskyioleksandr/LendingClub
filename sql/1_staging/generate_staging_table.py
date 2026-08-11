"""
Generates a PostgreSQL CREATE TABLE statement for a raw/staging table,
typing every column as TEXT, based on a CSV file's header row.

Usage:
    python generate_staging_table.py path/to/loans.csv

Notes:
- Only reads the header line, not the whole file, so this works fine
  even on a multi-GB CSV.
- Column names are lowercased and sanitized (spaces/invalid chars -> _)
  so they're safe to use unquoted in SQL.
- Output is written to staging_table.sql next to this script, and also
  printed to the console.
"""

import csv
import re
import sys
from pathlib import Path


def sanitize_column_name(name: str) -> str:
    name = name.strip().lower()
    name = re.sub(r"[^a-z0-9_]", "_", name)
    name = re.sub(r"_+", "_", name).strip("_")
    if not name:
        name = "unnamed_col"
    if name[0].isdigit():
        name = f"col_{name}"
    return name


def main():
    if len(sys.argv) != 2:
        print("Usage: python generate_staging_table.py path/to/loans.csv")
        sys.exit(1)

    csv_path = Path(sys.argv[1])
    if not csv_path.exists():
        print(f"File not found: {csv_path}")
        sys.exit(1)

    table_name = "loans_staging"

    with open(csv_path, "r", newline="", encoding="utf-8", errors="replace") as f:
        reader = csv.reader(f)
        header = next(reader)

    # Handle Lending Club's occasional "extra description line" before the
    # real header (some export variants include a first line like
    # "Notes offered by Prospectus..."). If the first row has only 1 field
    # but the file is clearly CSV, warn the user to check manually.
    if len(header) <= 1:
        print(
            "WARNING: only detected 1 column in the first line. "
            "Some Lending Club CSV exports have a junk description line "
            "before the real header — open the file and check the first "
            "couple of lines manually if this looks wrong."
        )

    seen = {}
    columns = []
    for raw_name in header:
        col = sanitize_column_name(raw_name)
        if col in seen:
            seen[col] += 1
            col = f"{col}_{seen[col]}"
        else:
            seen[col] = 0
        columns.append(col)

    col_defs = ",\n    ".join(f"{col} TEXT" for col in columns)

    sql = f"DROP TABLE IF EXISTS {table_name};\n\nCREATE TABLE {table_name} (\n    {col_defs}\n);\n"

    out_path = Path(__file__).parent / "staging_table.sql"
    out_path.write_text(sql, encoding="utf-8")

    print(f"Detected {len(columns)} columns.")
    print(f"SQL written to: {out_path}\n")
    print(sql)


if __name__ == "__main__":
    main()
