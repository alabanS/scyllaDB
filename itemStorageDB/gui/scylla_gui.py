from cassandra.cluster import Cluster
import pandas as pd
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
import traceback


class ScyllaGUI:
    def __init__(self):
        self.cluster = None
        self.session = None

        self.root = tk.Tk()
        self.root.title("ScyllaDB Manager - Ecommerce")
        self.root.geometry("1400x900")

        self.create_widgets()
        self.connect()

    def connect(self):
        try:
            self.cluster = Cluster(['localhost'], port=9042)
            self.session = self.cluster.connect()
            self.status_label.config(text="✅ Connected to ScyllaDB")

            self.session.execute("""
                CREATE KEYSPACE IF NOT EXISTS ecommerce 
                WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}
            """)
            self.session.set_keyspace('ecommerce')

        except Exception as e:
            self.status_label.config(text=f"❌ Error: {e}")
            messagebox.showerror("Connection Error", f"Failed to connect: {e}")

    def execute_query(self, query=None, event=None):
        if query is None:
            query = self.query_text.get("1.0", tk.END).strip()

        if query:
            try:
                self.clear_results()

                result = self.session.execute(query)
                df = pd.DataFrame(result)

                self.tree["columns"] = list(df.columns)

                for col in df.columns:
                    col_width = 120
                    if len(df) > 0:
                        max_len = max(df[col].astype(str).apply(len).max(), len(col))
                        col_width = min(max(100, max_len * 8), 300)

                    self.tree.heading(col, text=col)
                    self.tree.column(col, width=col_width, anchor=tk.W)

                for _, row in df.iterrows():
                    self.tree.insert("", "end", values=list(row.astype(str)))

                self.status_label.config(text=f"✅ Query executed. Found {len(df)} rows")
                self.log_text.insert(tk.END, f"✓ Executed: {query}\n")

            except Exception as e:
                error_msg = f"❌ Query error: {e}\n{traceback.format_exc()}"
                self.status_label.config(text=f"❌ Error: {e}")
                self.log_text.insert(tk.END, f"✗ Error: {query}\n{error_msg}\n")
                self.log_text.see(tk.END)
                messagebox.showerror("Query Error", f"Error executing query:\n{e}")

    def clear_results(self):
        for item in self.tree.get_children():
            self.tree.delete(item)

        current_columns = list(self.tree["columns"])
        for col in current_columns:
            self.tree.heading(col, text="")
            self.tree.column(col, width=0)

    def set_query(self, query):
        self.query_text.delete("1.0", tk.END)
        self.query_text.insert("1.0", query)
        self.query_text.focus_set()

    def paste_text(self, event=None):
        try:
            clipboard_text = self.root.clipboard_get()
            self.query_text.insert(tk.INSERT, clipboard_text)
            return "break"
        except tk.TclError:
            return "break"

    def copy_text(self, event=None):
        try:
            selected_text = self.query_text.get(tk.SEL_FIRST, tk.SEL_LAST)
            self.root.clipboard_clear()
            self.root.clipboard_append(selected_text)
            return "break"
        except tk.TclError:
            return "break"

    def cut_text(self, event=None):
        try:
            selected_text = self.query_text.get(tk.SEL_FIRST, tk.SEL_LAST)
            self.root.clipboard_clear()
            self.root.clipboard_append(selected_text)
            self.query_text.delete(tk.SEL_FIRST, tk.SEL_LAST)
            return "break"
        except tk.TclError:
            return "break"

    def copy_table_data(self, event=None):
        try:
            selected_items = self.tree.selection()
            if selected_items:
                data = []
                for item in selected_items:
                    values = self.tree.item(item)['values']
                    data.append('\t'.join(map(str, values)))

                self.root.clipboard_clear()
                self.root.clipboard_append('\n'.join(data))
                self.status_label.config(text="✅ Data copied to clipboard")
        except Exception as e:
            self.status_label.config(text=f"❌ Copy error: {e}")

    def show_context_menu(self, event):
        context_menu = tk.Menu(self.root, tearoff=0)
        context_menu.add_command(label="Вставить", command=self.paste_text)
        context_menu.add_command(label="Копировать", command=self.copy_text)
        context_menu.add_command(label="Вырезать", command=self.cut_text)
        context_menu.post(event.x_root, event.y_root)

    def create_quick_buttons(self, parent):
        """Компактные кнопки быстрых запросов"""
        queries = {
            "📊 Все": "SELECT * FROM product_by_id LIMIT 10;",
            "📱 Электроника": "SELECT * FROM products_by_category WHERE category = 'electronics';",
            "🍎 Apple": "SELECT * FROM products_by_brand WHERE brand = 'Apple';",
            "👕 Одежда": "SELECT * FROM products_by_category WHERE category = 'clothing';",
            "📚 Книги": "SELECT * FROM products_by_category WHERE category = 'books';",
            "🏠 Дом": "SELECT * FROM products_by_category WHERE category = 'home';",
            "⚽ Спорт": "SELECT * FROM products_by_category WHERE category = 'sports';",
            "🔢 Count": "SELECT COUNT(*) FROM product_by_id;",
            "📋 Таблицы": "SELECT table_name FROM system_schema.tables WHERE keyspace_name = 'ecommerce';",
            "🗑️ Очистить": "TRUNCATE product_by_id; TRUNCATE products_by_brand; TRUNCATE products_by_category;",
            "🗂️ DESC": "DESC TABLES;",
            "Samsung": "SELECT * FROM products_by_brand WHERE brand = 'Samsung';",
            "Nike": "SELECT * FROM products_by_brand WHERE brand = 'Nike';"
        }

        # Две строки компактных кнопок
        frame_row1 = ttk.Frame(parent)
        frame_row1.pack(fill=tk.X, pady=2)

        frame_row2 = ttk.Frame(parent)
        frame_row2.pack(fill=tk.X, pady=2)

        buttons_per_row = 7
        buttons = list(queries.items())

        for i, (text, query) in enumerate(buttons):
            if i < buttons_per_row:
                frame = frame_row1
            else:
                frame = frame_row2

            btn = ttk.Button(
                frame,
                text=text,
                width=12,
                command=lambda q=query: self.set_query(q)
            )
            btn.pack(side=tk.LEFT, padx=1, pady=1)

    def create_widgets(self):
        # Main container - вертикальное разделение
        main_paned = ttk.PanedWindow(self.root, orient=tk.VERTICAL)
        main_paned.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # Верхняя панель - запросы и кнопки (25%)
        top_panel = ttk.Frame(main_paned)
        main_paned.add(top_panel, weight=1)

        # Нижняя панель - результаты и логи (75%)
        bottom_panel = ttk.PanedWindow(main_paned, orient=tk.HORIZONTAL)
        main_paned.add(bottom_panel, weight=3)

        # Левая часть нижней панели - таблица результатов (70%)
        results_frame = ttk.LabelFrame(bottom_panel, text="Results", padding="5")
        bottom_panel.add(results_frame, weight=7)

        # Правая часть нижней панели - логи (30%)
        log_frame = ttk.LabelFrame(bottom_panel, text="Execution Log", padding="5")
        bottom_panel.add(log_frame, weight=3)

        # === ВЕРХНЯЯ ПАНЕЛЬ - ЗАПРОСЫ ===
        # Quick buttons
        self.create_quick_buttons(top_panel)

        # Query frame
        query_frame = ttk.Frame(top_panel)
        query_frame.pack(fill=tk.BOTH, expand=True, pady=5)

        ttk.Label(query_frame, text="CQL Query:", font=('Arial', 9, 'bold')).pack(anchor=tk.W)

        # Компактное поле для запроса
        self.query_text = scrolledtext.ScrolledText(query_frame, height=4, font=('Consolas', 10))
        self.query_text.pack(fill=tk.BOTH, expand=True, pady=2)
        self.query_text.insert("1.0", "SELECT * FROM product_by_id LIMIT 10;")

        # Bind shortcuts
        self.query_text.bind('<Control-v>', self.paste_text)
        self.query_text.bind('<Control-c>', self.copy_text)
        self.query_text.bind('<Control-x>', self.cut_text)
        self.query_text.bind('<Button-3>', self.show_context_menu)
        self.query_text.bind('<Control-Return>', lambda e: self.execute_query())

        # Компактные кнопки управления
        button_frame = ttk.Frame(query_frame)
        button_frame.pack(fill=tk.X, pady=2)

        ttk.Button(button_frame, text="Execute (Ctrl+Enter)",
                   command=lambda: self.execute_query()).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_frame, text="Clear Query",
                   command=lambda: self.query_text.delete("1.0", tk.END)).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_frame, text="Clear Results",
                   command=self.clear_results).pack(side=tk.LEFT, padx=2)

        # === НИЖНЯЯ ПАНЕЛЬ - РЕЗУЛЬТАТЫ ===
        # Treeview для результатов
        tree_container = ttk.Frame(results_frame)
        tree_container.pack(fill=tk.BOTH, expand=True)

        v_scrollbar = ttk.Scrollbar(tree_container, orient=tk.VERTICAL)
        h_scrollbar = ttk.Scrollbar(tree_container, orient=tk.HORIZONTAL)

        self.tree = ttk.Treeview(tree_container,
                                 yscrollcommand=v_scrollbar.set,
                                 xscrollcommand=h_scrollbar.set,
                                 show='headings',
                                 selectmode='extended')

        v_scrollbar.config(command=self.tree.yview)
        h_scrollbar.config(command=self.tree.xview)

        self.tree.grid(row=0, column=0, sticky='nsew')
        v_scrollbar.grid(row=0, column=1, sticky='ns')
        h_scrollbar.grid(row=1, column=0, sticky='ew')

        tree_container.grid_rowconfigure(0, weight=1)
        tree_container.grid_columnconfigure(0, weight=1)

        self.tree.bind('<Control-c>', self.copy_table_data)

        # === ЛОГИ ===
        self.log_text = scrolledtext.ScrolledText(log_frame, height=10, font=('Consolas', 9))
        self.log_text.pack(fill=tk.BOTH, expand=True)
        self.log_text.insert(tk.END, "Logs will appear here...\n")

        # === STATUS BAR ===
        status_frame = ttk.Frame(self.root)
        status_frame.pack(fill=tk.X, padx=10, pady=(0, 5))

        self.status_label = ttk.Label(status_frame, text="Ready to connect...", relief=tk.SUNKEN, anchor=tk.W)
        self.status_label.pack(side=tk.LEFT, fill=tk.X, expand=True)

        ttk.Label(status_frame, text="Ctrl+C: copy table | Right-click: context menu",
                  font=('Arial', 8)).pack(side=tk.RIGHT, padx=5)

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    app = ScyllaGUI()
    app.run()
