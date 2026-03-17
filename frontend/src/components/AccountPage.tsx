import { useEffect, useState } from "react";

import { apiFetch, clearSession, readToken, readUser, type SessionUser } from "../lib/session";

type AccountPageProps = {
  apiBaseUrl: string;
};

export default function AccountPage({ apiBaseUrl }: AccountPageProps) {
  const [user, setUser] = useState<SessionUser | null>(null);

  useEffect(() => {
    if (!readToken()) {
      window.location.replace("/");
      return;
    }

    setUser(readUser());
  }, []);

  const handleLogout = async () => {
    try {
      await apiFetch(apiBaseUrl, "/api/v1/auth/logout", { method: "DELETE" });
    } catch (error) {
      console.error(error);
    } finally {
      clearSession();
      window.location.replace("/");
    }
  };

  return (
    <div className="app-shell">
      <section className="app-panel narrow">
        <div className="panel-head">
          <div>
            <p className="panel-label">Account</p>
            <h1 className="panel-title">アカウント設定</h1>
            <p className="panel-subtitle">登録済みのアカウント情報を確認できます。</p>
          </div>
          <div className="toolbar">
            <button className="secondary-button" type="button" onClick={() => (window.location.href = "/todo")}>
              Todo一覧
            </button>
            <button className="ghost-button" type="button" onClick={handleLogout}>
              ログアウト
            </button>
          </div>
        </div>

        <div className="field-list">
          <div className="field">
            <span>メールアドレス</span>
            <strong>{user?.email ?? "-"}</strong>
          </div>
          <div className="field">
            <span>ユーザーID</span>
            <strong>{user?.id ?? "-"}</strong>
          </div>
        </div>
      </section>
    </div>
  );
}
