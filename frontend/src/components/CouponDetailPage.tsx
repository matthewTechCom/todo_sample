import { useEffect, useState } from "react";

import {
  apiFetch,
  clearSession,
  readToken,
  type CouponDetail,
} from "../lib/session";
import AppHeader from "./AppHeader";

type CouponDetailPageProps = {
  apiBaseUrl: string;
  slug?: string;
};

type CouponDetailResponse = {
  coupon?: CouponDetail;
};

const formatDateTime = (value: string) =>
  new Intl.DateTimeFormat("ja-JP", {
    year: "numeric",
    month: "numeric",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(value));

export default function CouponDetailPage({ apiBaseUrl, slug: initialSlug }: CouponDetailPageProps) {
  const [coupon, setCoupon] = useState<CouponDetail | null>(null);
  const [slug, setSlug] = useState(initialSlug ?? "");
  const [feedback, setFeedback] = useState({
    message: "クーポンを読み込んでいます...",
    kind: "neutral" as "neutral" | "success" | "error",
  });

  useEffect(() => {
    if (!readToken()) {
      window.location.replace("/");
      return;
    }

    if (!initialSlug) {
      const params = new URLSearchParams(window.location.search);
      setSlug(params.get("slug") ?? "");
      return;
    }

    void loadCoupon();
  }, [initialSlug]);

  useEffect(() => {
    if (!slug || !readToken()) return;
    void loadCoupon();
  }, [slug]);

  const moveToLogin = () => {
    clearSession();
    window.location.replace("/");
  };

  const loadCoupon = async () => {
    if (!slug) {
      setFeedback({ message: "クーポンが見つかりません。", kind: "error" });
      return;
    }

    try {
      const { response, payload } = await apiFetch<CouponDetailResponse>(
        apiBaseUrl,
        `/api/v1/coupons/${encodeURIComponent(slug)}`,
        {
          method: "GET",
        }
      );

      if (response.status === 401) {
        moveToLogin();
        return;
      }

      if (response.status === 404) {
        setFeedback({ message: "クーポンが見つかりません。", kind: "error" });
        return;
      }

      if (!response.ok || !payload?.coupon) {
        setFeedback({ message: "クーポン詳細の取得に失敗しました。", kind: "error" });
        return;
      }

      setCoupon(payload.coupon);
      setFeedback({ message: "", kind: "neutral" });
    } catch (error) {
      console.error(error);
      setFeedback({ message: "クーポンAPIへの接続に失敗しました。", kind: "error" });
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

  return (
    <div className="coupon-shell">
      <section className="coupon-frame detail-frame">
        <AppHeader
          menuItems={[
            {
              label: "アカウント情報",
              onClick: () => {
                window.location.href = "/account";
              },
            },
            {
              label: "ログアウト",
              onClick: () => {
                void handleLogout();
              },
              tone: "danger",
            },
          ]}
        />

        {coupon ? (
          <article className="detail-card">
            <div className="detail-hero-wrap">
              <img className="detail-hero-image" src={coupon.image_url} alt={coupon.title} />
            </div>

            <div className="detail-grid">
              <div className="detail-copy">
                <p className="eyebrow">{coupon.brand_name}</p>
                <h1 className="detail-title">{coupon.title}</h1>
                <p className="detail-discount">{coupon.discount_text}</p>
                <p className="detail-description">{coupon.description}</p>

                <div className="detail-pill-row">
                  <span className="detail-pill">{coupon.category}</span>
                  <span className="detail-pill subtle">配信中</span>
                </div>
              </div>

              <aside className="detail-sidebar">
                <section className="detail-panel">
                  <p className="section-label">Freshness Gauge</p>
                  <div className="freshness-copy large">
                    <span>残り熱量</span>
                    <strong>{coupon.freshness_ratio}%</strong>
                  </div>
                  <div className="freshness-gauge large" aria-hidden="true">
                    <div className="freshness-gauge-fill" style={{ width: `${coupon.freshness_ratio}%` }} />
                  </div>
                </section>

                <section className="detail-panel">
                  <p className="section-label">有効期間</p>
                  <p className="detail-panel-value">{formatDateTime(coupon.starts_at)}</p>
                  <p className="detail-panel-value">-</p>
                  <p className="detail-panel-value">{formatDateTime(coupon.ends_at)}</p>
                </section>
              </aside>
            </div>

            <div className="detail-section-grid">
              <section className="detail-section">
                <p className="section-label">利用条件</p>
                <p className="detail-body">{coupon.terms_and_conditions}</p>
              </section>

              <section className="detail-section accent">
                <p className="section-label">How To Use</p>
                <ol className="detail-steps">
                  <li>対象商品をカゴに追加します。</li>
                  <li>レジ前にこの画面を提示します。</li>
                  <li>有効期限内であればその場で値引きされます。</li>
                </ol>
              </section>
            </div>
          </article>
        ) : null}

        <div className={`feedback ${feedback.kind}`} role="status" aria-live="polite">
          {feedback.message}
        </div>
      </section>
    </div>
  );
}
