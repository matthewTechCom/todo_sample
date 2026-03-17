import { useEffect, useState, type FormEvent } from "react";

import {
  authFetch,
  extractToken,
  persistSession,
  readToken,
  type SessionUser,
} from "../lib/session";

type AuthPageProps = {
  apiBaseUrl: string;
};

type AuthPayload = {
  user?: SessionUser;
  token?: string;
  errors?: string[];
};

export default function AuthPage({ apiBaseUrl }: AuthPageProps) {
  const [mode, setMode] = useState<"login" | "signup">("login");
  const [feedback, setFeedback] = useState({
    message: "",
    kind: "neutral" as "neutral" | "success" | "error",
  });
  const [loginEmail, setLoginEmail] = useState("");
  const [loginPassword, setLoginPassword] = useState("");
  const [signupEmail, setSignupEmail] = useState("");
  const [signupPassword, setSignupPassword] = useState("");
  const [signupPasswordConfirmation, setSignupPasswordConfirmation] = useState("");

  useEffect(() => {
    if (readToken()) {
      window.location.replace("/todo");
    }
  }, []);

  const handleLogin = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setFeedback({ message: "ログイン中...", kind: "neutral" });

    try {
      const { response, payload } = await authFetch<AuthPayload>(apiBaseUrl, "/api/v1/auth/login", {
        method: "POST",
        body: JSON.stringify({ user: { email: loginEmail.trim(), password: loginPassword } }),
      });

      if (!response.ok || !payload?.user) {
        setFeedback({
          message: "ログインに失敗しました。入力内容を確認してください。",
          kind: "error",
        });
        return;
      }

      const token = extractToken(response, payload);
      if (!token) {
        setFeedback({ message: "ログイン情報の保存に失敗しました。", kind: "error" });
        return;
      }

      persistSession(token, payload.user);
      window.location.href = "/todo";
    } catch (error) {
      console.error(error);
      setFeedback({ message: "ログインAPIへの接続に失敗しました。", kind: "error" });
    }
  };

  const handleSignup = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (signupPassword !== signupPasswordConfirmation) {
      setFeedback({
        message: "パスワードと確認用パスワードが一致しません。",
        kind: "error",
      });
      return;
    }

    setFeedback({ message: "登録中...", kind: "neutral" });

    try {
      const { response, payload } = await authFetch<AuthPayload>(apiBaseUrl, "/api/v1/auth/signup", {
        method: "POST",
        body: JSON.stringify({
          user: {
            email: signupEmail.trim(),
            password: signupPassword,
            password_confirmation: signupPasswordConfirmation,
          },
        }),
      });

      if (!response.ok || !payload?.user) {
        setFeedback({
          message: "登録に失敗しました。入力内容を確認してください。",
          kind: "error",
        });
        return;
      }

      const token = extractToken(response, payload);
      if (!token) {
        setFeedback({ message: "登録情報の保存に失敗しました。", kind: "error" });
        return;
      }

      persistSession(token, payload.user);
      window.location.href = "/todo";
    } catch (error) {
      console.error(error);
      setFeedback({ message: "登録APIへの接続に失敗しました。", kind: "error" });
    }
  };

  return (
    <div className="app-shell">
      <section className="app-panel narrow">
        <div className="panel-head">
          <div>
            <p className="panel-label">Auth</p>
            <h1 className="panel-title">アカウント</h1>
          </div>
          <div className="mode-switch" role="tablist" aria-label="認証モード切替">
            <button
              className={`mode-button ${mode === "login" ? "is-active" : ""}`}
              type="button"
              onClick={() => setMode("login")}
            >
              ログイン
            </button>
            <button
              className={`mode-button ${mode === "signup" ? "is-active" : ""}`}
              type="button"
              onClick={() => setMode("signup")}
            >
              新規登録
            </button>
          </div>
        </div>

        <form className={`auth-form ${mode === "login" ? "" : "is-hidden"}`} onSubmit={handleLogin}>
          <label>
            <span>メールアドレス</span>
            <input
              type="email"
              autoComplete="email"
              required
              value={loginEmail}
              onChange={(event) => setLoginEmail(event.target.value)}
            />
          </label>
          <label>
            <span>パスワード</span>
            <input
              type="password"
              autoComplete="current-password"
              minLength={6}
              required
              value={loginPassword}
              onChange={(event) => setLoginPassword(event.target.value)}
            />
          </label>
          <button className="primary-button" type="submit">
            ログインする
          </button>
        </form>

        <form className={`auth-form ${mode === "signup" ? "" : "is-hidden"}`} onSubmit={handleSignup}>
          <label>
            <span>メールアドレス</span>
            <input
              type="email"
              autoComplete="email"
              required
              value={signupEmail}
              onChange={(event) => setSignupEmail(event.target.value)}
            />
          </label>
          <label>
            <span>パスワード</span>
            <input
              type="password"
              autoComplete="new-password"
              minLength={6}
              required
              value={signupPassword}
              onChange={(event) => setSignupPassword(event.target.value)}
            />
          </label>
          <label>
            <span>確認用パスワード</span>
            <input
              type="password"
              autoComplete="new-password"
              minLength={6}
              required
              value={signupPasswordConfirmation}
              onChange={(event) => setSignupPasswordConfirmation(event.target.value)}
            />
          </label>
          <button className="primary-button" type="submit">
            アカウントを作成
          </button>
        </form>

        <div className={`feedback ${feedback.kind}`} role="status" aria-live="polite">
          {feedback.message}
        </div>
      </section>
    </div>
  );
}
