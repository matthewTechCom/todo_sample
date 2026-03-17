import { useEffect, useState, type FormEvent } from "react";

import {
  apiFetch,
  clearSession,
  readToken,
  readUser,
  type Todo,
} from "../lib/session";

type TodoPageProps = {
  apiBaseUrl: string;
};

type TodosPayload = {
  todos?: Todo[];
};

type TodoPayload = {
  todo?: Todo;
  errors?: string[];
};

export default function TodoPage({ apiBaseUrl }: TodoPageProps) {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [newTitle, setNewTitle] = useState("");
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editingTitle, setEditingTitle] = useState("");
  const [feedback, setFeedback] = useState({
    message: "",
    kind: "neutral" as "neutral" | "success" | "error",
  });
  const [userEmail, setUserEmail] = useState<string>("");

  useEffect(() => {
    if (!readToken()) {
      window.location.replace("/");
      return;
    }

    const user = readUser();
    setUserEmail(user?.email ?? "");
    void loadTodos();
  }, []);

  const moveToLogin = () => {
    clearSession();
    window.location.replace("/");
  };

  const loadTodos = async () => {
    try {
      const { response, payload } = await apiFetch<TodosPayload>(apiBaseUrl, "/api/v1/todos", {
        method: "GET",
      });

      if (response.status === 401) {
        moveToLogin();
        return;
      }

      if (!response.ok) {
        setFeedback({ message: "Todo の取得に失敗しました。", kind: "error" });
        return;
      }

      setTodos(payload?.todos ?? []);
    } catch (error) {
      console.error(error);
      setFeedback({ message: "Todo API への接続に失敗しました。", kind: "error" });
    }
  };

  const handleLogout = async () => {
    try {
      await apiFetch(apiBaseUrl, "/api/v1/auth/logout", { method: "DELETE" });
    } catch (error) {
      console.error(error);
    } finally {
      moveToLogin();
    }
  };

  const handleCreate = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const title = newTitle.trim();
    if (!title) return;

    try {
      const { response } = await apiFetch<TodoPayload>(apiBaseUrl, "/api/v1/todos", {
        method: "POST",
        body: JSON.stringify({ todo: { title } }),
      });

      if (response.status === 401) {
        moveToLogin();
        return;
      }

      if (!response.ok) {
        setFeedback({ message: "Todo の追加に失敗しました。", kind: "error" });
        return;
      }

      setNewTitle("");
      setFeedback({ message: "Todo を追加しました。", kind: "success" });
      void loadTodos();
    } catch (error) {
      console.error(error);
      setFeedback({ message: "Todo API への接続に失敗しました。", kind: "error" });
    }
  };

  const handleToggle = async (todo: Todo, completed: boolean) => {
    try {
      const { response } = await apiFetch<TodoPayload>(apiBaseUrl, `/api/v1/todos/${todo.id}`, {
        method: "PATCH",
        body: JSON.stringify({ todo: { title: todo.title, completed } }),
      });

      if (response.status === 401) {
        moveToLogin();
        return;
      }

      if (!response.ok) {
        setFeedback({ message: "Todo の更新に失敗しました。", kind: "error" });
        return;
      }

      setFeedback({ message: "Todo を更新しました。", kind: "success" });
      void loadTodos();
    } catch (error) {
      console.error(error);
      setFeedback({ message: "Todo API への接続に失敗しました。", kind: "error" });
    }
  };

  const handleDelete = async (id: number) => {
    try {
      const { response } = await apiFetch(apiBaseUrl, `/api/v1/todos/${id}`, {
        method: "DELETE",
      });

      if (response.status === 401) {
        moveToLogin();
        return;
      }

      if (!response.ok) {
        setFeedback({ message: "Todo の削除に失敗しました。", kind: "error" });
        return;
      }

      setFeedback({ message: "Todo を削除しました。", kind: "success" });
      if (editingId === id) {
        setEditingId(null);
        setEditingTitle("");
      }
      void loadTodos();
    } catch (error) {
      console.error(error);
      setFeedback({ message: "Todo API への接続に失敗しました。", kind: "error" });
    }
  };

  const startEditing = (todo: Todo) => {
    setEditingId(todo.id);
    setEditingTitle(todo.title);
  };

  const cancelEditing = () => {
    setEditingId(null);
    setEditingTitle("");
  };

  const handleSave = async (todo: Todo) => {
    const title = editingTitle.trim();
    if (!title) {
      setFeedback({ message: "Todo の内容を入力してください。", kind: "error" });
      return;
    }

    try {
      const { response } = await apiFetch<TodoPayload>(apiBaseUrl, `/api/v1/todos/${todo.id}`, {
        method: "PATCH",
        body: JSON.stringify({ todo: { title, completed: todo.completed } }),
      });

      if (response.status === 401) {
        moveToLogin();
        return;
      }

      if (!response.ok) {
        setFeedback({ message: "Todo の更新に失敗しました。", kind: "error" });
        return;
      }

      cancelEditing();
      setFeedback({ message: "Todo を更新しました。", kind: "success" });
      void loadTodos();
    } catch (error) {
      console.error(error);
      setFeedback({ message: "Todo API への接続に失敗しました。", kind: "error" });
    }
  };

  return (
    <div className="app-shell">
      <section className="app-panel">
        <div className="panel-head">
          <div>
            <p className="panel-label">Todo App</p>
            <h1 className="panel-title">Todo リスト</h1>
            <p className="panel-subtitle">{userEmail ? `${userEmail} でログイン中` : "Todo を管理"}</p>
          </div>
          <div className="toolbar">
            <button className="secondary-button" type="button" onClick={() => (window.location.href = "/account")}>
              アカウント設定
            </button>
            <button className="ghost-button" type="button" onClick={handleLogout}>
              ログアウト
            </button>
          </div>
        </div>

        <form className="todo-form" onSubmit={handleCreate}>
          <label className="todo-input-wrap">
            <span>新しいTodo</span>
            <input
              type="text"
              maxLength={255}
              required
              value={newTitle}
              onChange={(event) => setNewTitle(event.target.value)}
            />
          </label>
          <button className="primary-button" type="submit">
            追加
          </button>
        </form>

        <div className="todo-section-head">
          <p>一覧</p>
          <span>{todos.length}件</span>
        </div>

        <ul className="todo-list">
          {todos.length === 0 ? (
            <li className="todo-empty">まだTodoがありません。</li>
          ) : (
            todos.map((todo) => (
              <li className="todo-item" key={todo.id}>
                <div className="todo-main">
                  <label className="todo-check">
                    <input
                      type="checkbox"
                      checked={todo.completed}
                      onChange={(event) => void handleToggle(todo, event.target.checked)}
                    />
                    {editingId === todo.id ? (
                      <span className="is-hidden">{todo.title}</span>
                    ) : (
                      <span className={`todo-title ${todo.completed ? "is-completed" : ""}`}>{todo.title}</span>
                    )}
                  </label>

                  {editingId === todo.id ? (
                    <form
                      className="todo-edit-form"
                      onSubmit={(event) => {
                        event.preventDefault();
                        void handleSave(todo);
                      }}
                    >
                      <input
                        className="todo-edit-input"
                        type="text"
                        maxLength={255}
                        required
                        value={editingTitle}
                        onChange={(event) => setEditingTitle(event.target.value)}
                      />
                      <div className="todo-edit-actions">
                        <button className="secondary-button small-button" type="submit">
                          保存
                        </button>
                        <button className="ghost-button small-button" type="button" onClick={cancelEditing}>
                          キャンセル
                        </button>
                      </div>
                    </form>
                  ) : null}
                </div>

                <div className="todo-actions">
                  <button className="secondary-button small-button" type="button" onClick={() => startEditing(todo)}>
                    編集
                  </button>
                  <button className="danger-button small-button" type="button" onClick={() => void handleDelete(todo.id)}>
                    削除
                  </button>
                </div>
              </li>
            ))
          )}
        </ul>

        <div className={`feedback ${feedback.kind}`} role="status" aria-live="polite">
          {feedback.message}
        </div>
      </section>
    </div>
  );
}
