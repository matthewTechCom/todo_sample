import { useEffect, useState } from "react";

import { apiFetch, clearSession, readToken, readUser, type SessionUser } from "../lib/session";
import AppHeader from "./AppHeader";

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
    <div className="coupon-shell">
      <section className="coupon-frame account-frame">
        <AppHeader
          menuItems={[
            {
              label: "ログアウト",
              onClick: () => {
                void handleLogout();
              },
              tone: "danger",
            },
          ]}
        />

        <div className="panel-head">
          <div>
            <p className="panel-label">Account</p>
            <h1 className="panel-title">アカウント情報</h1>
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

        <div className="account-footer">
          <button className="text-link" type="button" onClick={() => void handleLogout()}>
            ログアウト
          </button>
        </div>
      </section>
    </div>
  );
}
