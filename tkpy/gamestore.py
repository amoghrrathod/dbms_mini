# game_store_app.py
import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector
import bcrypt

db_config = {
    'host': 'localhost',
    'user': 'user1',
    'password': '', 
    'database': 'gamestoredb'
}

# --- BACKEND DATABASE LOGIC ---

def connect_db():
    """Establishes a connection to the database."""
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except mysql.connector.Error as err:
        messagebox.showerror("Database Error", f"Failed to connect to database: {err}")
        return None

def register_user(username, email, password, dob):
    """Hashes password and registers a new user in the database."""
    if not (username and email and password):
        return "Username, email, and password are required.", False

    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    
    conn = connect_db()
    if not conn: return "Database connection failed.", False
    
    try:
        cursor = conn.cursor()
        query = "INSERT INTO users (user_name, email, password, dob) VALUES (%s, %s, %s, %s)"
        cursor.execute(query, (username, email, hashed_password, dob if dob else None))
        conn.commit()
        return "User created successfully! Please log in.", True
    except mysql.connector.Error as err:
        if err.errno == 1062: # Duplicate entry
            return "An account with this email already exists.", False
        return f"Error: {err}", False
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

def login_user(email, password):
    """Verifies user credentials against the database."""
    if not (email and password):
        return "Email and password cannot be empty.", None

    conn = connect_db()
    if not conn: return "Database connection failed.", None

    try:
        cursor = conn.cursor(dictionary=True)
        query = "SELECT * FROM users WHERE email = %s"
        cursor.execute(query, (email,))
        user = cursor.fetchone()

        if user and bcrypt.checkpw(password.encode('utf-8'), user['password'].encode('utf-8')):
            return "Login successful!", {'id': user['user_id'], 'name': user['user_name']}
        else:
            return "Invalid email or password.", None
    except mysql.connector.Error as err:
        return f"Error: {err}", None
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

def get_all_games():
    """Fetches a list of all games from the database."""
    conn = connect_db()
    if not conn: return []
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT game_id, game_name, price FROM games ORDER BY game_name")
        games = cursor.fetchall()
        return games
    except mysql.connector.Error as err:
        messagebox.showerror("Error", f"Could not fetch games: {err}")
        return []
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

def get_game_details(game_id):
    """Fetches detailed information for a specific game."""
    conn = connect_db()
    if not conn: return None
    try:
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT g.game_name, g.description, g.release_date, g.price, g.age_rating, 
                   p.publisher_name, d.studio
            FROM games g
            LEFT JOIN publishers p ON g.publisher_id = p.publisher_id
            LEFT JOIN developers d ON g.dev_id = d.dev_id
            WHERE g.game_id = %s
        """
        cursor.execute(query, (game_id,))
        details = cursor.fetchone()
        return details
    except mysql.connector.Error as err:
        messagebox.showerror("Error", f"Could not fetch game details: {err}")
        return None
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()
            
def purchase_game(user_id, game_id):
    """Adds a game to a user's library."""
    conn = connect_db()
    if not conn: return "Database connection failed.", False
    try:
        cursor = conn.cursor()
        query = "INSERT INTO user_library (user_id, game_id, purchase_date) VALUES (%s, %s, NOW())"
        cursor.execute(query, (user_id, game_id))
        conn.commit()
        return "Game purchased successfully!", True
    except mysql.connector.Error as err:
        if err.errno == 1062: # Duplicate entry
            return "You already own this game.", False
        return f"Error purchasing game: {err}", False
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


# --- TKINTER UI ---

class GameStoreApp(tk.Tk):
    """Main application controller."""
    def __init__(self):
        super().__init__()
        self.title("GameStoreDB")
        self.geometry("900x600")
        
        self.logged_in_user = None

        container = ttk.Frame(self)
        container.pack(side="top", fill="both", expand=True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)

        self.frames = {}
        for F in (LoginPage, SignupPage, MainPage):
            page_name = F.__name__
            frame = F(parent=container, controller=self)
            self.frames[page_name] = frame
            frame.grid(row=0, column=0, sticky="nsew")

        self.show_frame("LoginPage")

    def show_frame(self, page_name):
        frame = self.frames[page_name]
        frame.tkraise()
        if page_name == "MainPage": # Refresh game list when showing main page
            frame.populate_games_list()


class LoginPage(ttk.Frame):
    """Login screen GUI."""
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        
        main_frame = ttk.Frame(self, padding="20 20 20 20")
        main_frame.place(relx=0.5, rely=0.5, anchor='center')

        ttk.Label(main_frame, text="Login", font=("Arial", 24, "bold")).pack(pady=10)
        
        ttk.Label(main_frame, text="Email").pack(fill='x', padx=5)
        self.email_entry = ttk.Entry(main_frame, width=40)
        self.email_entry.pack(pady=5)
        
        ttk.Label(main_frame, text="Password").pack(fill='x', padx=5)
        self.password_entry = ttk.Entry(main_frame, show="*", width=40)
        self.password_entry.pack(pady=5)
        
        login_button = ttk.Button(main_frame, text="Login", command=self.handle_login)
        login_button.pack(pady=20, fill='x')

        signup_label = ttk.Label(main_frame, text="Don't have an account? Sign Up", foreground="blue", cursor="hand2")
        signup_label.pack()
        signup_label.bind("<Button-1>", lambda e: controller.show_frame("SignupPage"))

    def handle_login(self):
        email = self.email_entry.get()
        password = self.password_entry.get()
        
        message, user_info = login_user(email, password)
        
        if user_info:
            self.controller.logged_in_user = user_info
            messagebox.showinfo("Success", message)
            self.email_entry.delete(0, 'end')
            self.password_entry.delete(0, 'end')
            self.controller.show_frame("MainPage")
        else:
            messagebox.showerror("Login Failed", message)


class SignupPage(ttk.Frame):
    """User registration screen GUI."""
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller

        main_frame = ttk.Frame(self, padding="20 20 20 20")
        main_frame.place(relx=0.5, rely=0.5, anchor='center')

        ttk.Label(main_frame, text="Create Account", font=("Arial", 24, "bold")).pack(pady=10)

        ttk.Label(main_frame, text="Username").pack(fill='x', padx=5)
        self.username_entry = ttk.Entry(main_frame, width=40)
        self.username_entry.pack(pady=5)
        
        ttk.Label(main_frame, text="Email").pack(fill='x', padx=5)
        self.email_entry = ttk.Entry(main_frame, width=40)
        self.email_entry.pack(pady=5)
        
        ttk.Label(main_frame, text="Password").pack(fill='x', padx=5)
        self.password_entry = ttk.Entry(main_frame, show="*", width=40)
        self.password_entry.pack(pady=5)
        
        ttk.Label(main_frame, text="Date of Birth (YYYY-MM-DD)").pack(fill='x', padx=5)
        self.dob_entry = ttk.Entry(main_frame, width=40)
        self.dob_entry.pack(pady=5)
        
        signup_button = ttk.Button(main_frame, text="Sign Up", command=self.handle_signup)
        signup_button.pack(pady=20, fill='x')

        login_label = ttk.Label(main_frame, text="Already have an account? Login", foreground="blue", cursor="hand2")
        login_label.pack()
        login_label.bind("<Button-1>", lambda e: controller.show_frame("LoginPage"))

    def handle_signup(self):
        username = self.username_entry.get()
        email = self.email_entry.get()
        password = self.password_entry.get()
        dob = self.dob_entry.get()
        
        message, success = register_user(username, email, password, dob)
        
        if success:
            messagebox.showinfo("Success", message)
            self.controller.show_frame("LoginPage")
        else:
            messagebox.showerror("Registration Failed", message)


class MainPage(ttk.Frame):
    """Main application interface after login."""
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.games_data = {} # To store game data by name

        # Configure layout
        self.columnconfigure(0, weight=1)
        self.columnconfigure(1, weight=3)
        self.rowconfigure(1, weight=1)

        # Header
        header_frame = ttk.Frame(self, padding="10")
        header_frame.grid(row=0, column=0, columnspan=2, sticky="ew")
        self.welcome_label = ttk.Label(header_frame, text="Welcome!", font=("Arial", 16))
        self.welcome_label.pack(side="left")
        logout_button = ttk.Button(header_frame, text="Logout", command=self.handle_logout)
        logout_button.pack(side="right")
        
        # Left Panel (Game List)
        list_frame = ttk.Frame(self, padding="10")
        list_frame.grid(row=1, column=0, sticky="nsw")
        ttk.Label(list_frame, text="Games", font=("Arial", 14, "bold")).pack(anchor="w")
        self.games_listbox = tk.Listbox(list_frame, width=40, font=("Arial", 12))
        self.games_listbox.pack(fill="both", expand=True)
        self.games_listbox.bind('<<ListboxSelect>>', self.show_game_details)

        # Right Panel (Game Details)
        details_frame = ttk.Frame(self, padding="20")
        details_frame.grid(row=1, column=1, sticky="nsew")
        self.details_text = tk.Text(details_frame, wrap="word", state="disabled", font=("Arial", 12), height=15)
        self.details_text.pack(fill="both", expand=True, pady=(0, 10))
        
        self.purchase_button = ttk.Button(details_frame, text="Purchase", state="disabled", command=self.handle_purchase)
        self.purchase_button.pack(fill="x", ipady=5)

    def populate_games_list(self):
        self.welcome_label.config(text=f"Welcome, {self.controller.logged_in_user['name']}!")
        self.games_listbox.delete(0, 'end')
        self.games_data.clear()

        games = get_all_games()
        for game in games:
            display_name = game['game_name']
            self.games_listbox.insert('end', display_name)
            self.games_data[display_name] = game # Store full game data

    def show_game_details(self, event):
        selection_indices = self.games_listbox.curselection()
        if not selection_indices:
            return
            
        selected_game_name = self.games_listbox.get(selection_indices[0])
        game_id = self.games_data[selected_game_name]['game_id']
        
        details = get_game_details(game_id)
        
        self.details_text.config(state="normal")
        self.details_text.delete("1.0", "end")
        if details:
            info = (
                f"Title: {details['game_name']}\n\n"
                f"Price: ${details['price']}\n\n"
                f"Description: {details['description']}\n\n"
                f"Publisher: {details['publisher_name'] or 'N/A'}\n"
                f"Developer: {details['studio'] or 'N/A'}\n"
                f"Release Date: {details['release_date']}\n"
                f"Age Rating: {details['age_rating']}"
            )
            self.details_text.insert("1.0", info)
            self.purchase_button.config(state="normal")
        else:
            self.details_text.insert("1.0", "Could not load details for this game.")
            self.purchase_button.config(state="disabled")
        self.details_text.config(state="disabled")

    def handle_purchase(self):
        selection_indices = self.games_listbox.curselection()
        if not selection_indices:
            messagebox.showwarning("No Selection", "Please select a game to purchase.")
            return

        selected_game_name = self.games_listbox.get(selection_indices[0])
        game_id = self.games_data[selected_game_name]['game_id']
        user_id = self.controller.logged_in_user['id']

        if messagebox.askyesno("Confirm Purchase", f"Do you want to purchase {selected_game_name}?"):
            message, success = purchase_game(user_id, game_id)
            if success:
                messagebox.showinfo("Success", message)
            else:
                messagebox.showerror("Purchase Failed", message)

    def handle_logout(self):
        self.controller.logged_in_user = None
        self.controller.show_frame("LoginPage")


if __name__ == "__main__":
    app = GameStoreApp()
    app.mainloop()
