import os
import zipfile
from pathlib import Path

def create_flutter_minimal_zip(output_filename="kakeibo.zip"):
    # AIが構造を理解するために含めるべきファイル・ディレクトリ
    included_patterns = [
        "lib/main.dart",                   # ソースコードの本体
        "pubspec.yaml",           # 依存関係・プロジェクト設定
        "analysis_options.yaml",  # Lint設定（コーディング規約）
        "README.md",              # プロジェクト概要
    ]

    project_root = Path.cwd()
    
    with zipfile.ZipFile(output_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        print(f"--- 圧縮を開始します: {output_filename} ---")
        
        for pattern in included_patterns:
            path = project_root / pattern
            
            if path.is_dir():
                # ディレクトリ内のファイルを再帰的に追加
                for file_path in path.rglob('*'):
                    if file_path.is_file() and not file_path.name.startswith('.'):
                        relative_path = file_path.relative_to(project_root)
                        zipf.write(file_path, relative_path)
                        print(f"追加: {relative_path}")
            
            elif path.is_file():
                # 単一ファイルを追加
                zipf.write(path, path.name)
                print(f"追加: {path.name}")

    print(f"\n完了しました！ 生成ファイル: {os.path.abspath(output_filename)}")

if __name__ == "__main__":
    create_flutter_minimal_zip()