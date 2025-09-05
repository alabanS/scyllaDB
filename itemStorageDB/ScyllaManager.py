from cassandra.cluster import Cluster
import pandas as pd
import tkinter as tk
from tkinter import ttk, scrolledtext


class ScyllaGUI:
    def __init__(self):
        self.cluster = None
        self.session = None

        self.root = tk.Tk()
        self.root.title("ScyllaDB Manager")
        self.root.geometry("1200x800")

        self.create_widgets()
        self.connect()  # Автоподключение

    def connect(self):
        try:
            self.cluster = Cluster(['localhost'], port=9042)
            self.session = self.cluster.connect('ecommerce')
            self.status_label.config(text="✅ Connected to ScyllaDB")
        except Exception as e:
            self.status_label.config(text=f"❌ Error: {e}")

    def execute_query(self):
        query = self.query_text.get("1.0", tk.END).strip()
        if query:
            try:
                result = self.session.execute(query)
                df = pd.DataFrame(result)

                # Clear previous results
                for item in self.tree.get_children():
                    self.tree.delete(item)

                # Clear previous columns
                for col in self.tree['columns']:
                    self.tree.heading(col, text="")
                    self.tree.column(col, width=0)

                # Add new columns
                self.tree["columns"] = list(df.columns)

                # Configure columns with better widths
                for col in df.columns:
                    # Определяем ширину колонки по содержимому
                    col_width = 150  # минимальная ширина
                    if len(df) > 0:
                        # Ширина по самому длинному значению в колонке
                        max_len = max(df[col].astype(str).apply(len).max(), len(col))
                        col_width = min(max(100, max_len * 8), 300)  # ограничиваем максимальную ширину

                    self.tree.heading(col, text=col, anchor=tk.W)
                    self.tree.column(col, width=col_width, anchor=tk.W, stretch=False)

                # Add data
                for _, row in df.iterrows():
                    self.tree.insert("", "end", values=list(row.astype(str)))

                self.status_label.config(text=f"✅ Query executed. Found {len(df)} rows")

            except Exception as e:
                self.status_label.config(text=f"❌ Query error: {e}")

    def create_widgets(self):
        # Main container with padding
        main_container = ttk.Frame(self.root, padding="10")
        main_container.pack(fill=tk.BOTH, expand=True)

        # Query section
        query_frame = ttk.LabelFrame(main_container, text="CQL Query", padding="10")
        query_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Label(query_frame, text="Enter your CQL query:").pack(anchor=tk.W)

        # Query text area with better font
        self.query_text = scrolledtext.ScrolledText(query_frame, height=6, font=('Consolas', 10))
        self.query_text.pack(fill=tk.X, pady=5)
        self.query_text.insert("1.0", "SELECT * FROM product_by_id LIMIT 10;")

        # Buttons frame
        buttons_frame = ttk.Frame(query_frame)
        buttons_frame.pack(fill=tk.X)

        ttk.Button(buttons_frame, text="Execute Query", command=self.execute_query).pack(side=tk.LEFT)
        ttk.Button(buttons_frame, text="Clear", command=lambda: self.query_text.delete("1.0", tk.END)).pack(
            side=tk.LEFT, padx=5)

        # Results section
        results_frame = ttk.LabelFrame(main_container, text="Results", padding="10")
        results_frame.pack(fill=tk.BOTH, expand=True)

        # Treeview with both scrollbars
        tree_container = ttk.Frame(results_frame)
        tree_container.pack(fill=tk.BOTH, expand=True)

        # Vertical scrollbar
        v_scrollbar = ttk.Scrollbar(tree_container, orient=tk.VERTICAL)

        # Horizontal scrollbar
        h_scrollbar = ttk.Scrollbar(tree_container, orient=tk.HORIZONTAL)

        # Treeview
        self.tree = ttk.Treeview(tree_container,
                                 yscrollcommand=v_scrollbar.set,
                                 xscrollcommand=h_scrollbar.set,
                                 show='headings')

        v_scrollbar.config(command=self.tree.yview)
        h_scrollbar.config(command=self.tree.xview)

        # Grid layout for proper sizing
        self.tree.grid(row=0, column=0, sticky='nsew')
        v_scrollbar.grid(row=0, column=1, sticky='ns')
        h_scrollbar.grid(row=1, column=0, sticky='ew')

        tree_container.grid_rowconfigure(0, weight=1)
        tree_container.grid_columnconfigure(0, weight=1)

        # Status bar
        status_frame = ttk.Frame(main_container)
        status_frame.pack(fill=tk.X, pady=(10, 0))

        self.status_label = ttk.Label(status_frame, text="Ready to connect...", relief=tk.SUNKEN, anchor=tk.W)
        self.status_label.pack(fill=tk.X)

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    app = ScyllaGUI()
    app.run()
