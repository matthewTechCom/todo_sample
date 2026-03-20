import {
  startTransition,
  useDeferredValue,
  useEffect,
  useState,
} from "react";

import {
  apiFetch,
  clearSession,
  readToken,
  type CouponListItem,
} from "../lib/session";
import AppHeader from "./AppHeader";

type CouponListPageProps = {
  apiBaseUrl: string;
};

type CouponListResponse = {
  coupons?: CouponListItem[];
  meta?: {
    total_count?: number;
    categories?: string[];
    query?: string;
    selected_category?: string | null;
  };
};

const formatDate = (value: string) =>
  new Intl.DateTimeFormat("ja-JP", {
    month: "numeric",
    day: "numeric",
    weekday: "short",
  }).format(new Date(value));

const freshnessLabel = (ratio: number) => {
  if (ratio >= 75) return "残りわずか";
  if (ratio >= 45) return "期間限定";
  return "人気上昇中";
};

export default function CouponListPage({ apiBaseUrl }: CouponListPageProps) {
  const [coupons, setCoupons] = useState<CouponListItem[]>([]);
  const [categories, setCategories] = useState<string[]>([]);
  const [searchText, setSearchText] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string>("");
  const [feedback, setFeedback] = useState({
    message: "",
    kind: "neutral" as "neutral" | "success" | "error",
  });
  const [isLoading, setIsLoading] = useState(true);
  const deferredSearchText = useDeferredValue(searchText.trim());

  useEffect(() => {
    if (!readToken()) {
      window.location.replace("/");
      return;
    }

    const query = new URLSearchParams(window.location.search);
    setSearchText(query.get("q") ?? "");
    setSelectedCategory(query.get("category") ?? "");
  }, []);

  useEffect(() => {
    if (!readToken()) return;

    void loadCoupons(deferredSearchText, selectedCategory);
  }, [apiBaseUrl, deferredSearchText, selectedCategory]);

  const moveToLogin = () => {
    clearSession();
    window.location.replace("/");
  };

  const updateQueryString = (query: string, category: string) => {
    const params = new URLSearchParams();
    if (query) params.set("q", query);
    if (category) params.set("category", category);

    const next = params.toString();
    const path = next ? `/coupons?${next}` : "/coupons";
    window.history.replaceState({}, "", path);
  };

  const loadCoupons = async (query: string, category: string) => {
    setIsLoading(true);
    updateQueryString(query, category);

    const params = new URLSearchParams();
    if (query) params.set("q", query);
    if (category) params.set("category", category);

    const path = params.toString() ? `/api/v1/coupons?${params}` : "/api/v1/coupons";

    try {
      const { response, payload } = await apiFetch<CouponListResponse>(apiBaseUrl, path, {
        method: "GET",
      });

      if (response.status === 401) {
        moveToLogin();
        return;
      }

      if (!response.ok) {
        setFeedback({ message: "クーポン一覧の取得に失敗しました。", kind: "error" });
        return;
      }

      startTransition(() => {
        setCoupons(payload?.coupons ?? []);
        setCategories(payload?.meta?.categories ?? []);
      });
      setFeedback({
        message: payload?.coupons?.length ? "" : "該当するクーポンがありません。",
        kind: "neutral",
      });
    } catch (error) {
      console.error(error);
      setFeedback({ message: "クーポンAPIへの接続に失敗しました。", kind: "error" });
    } finally {
      setIsLoading(false);
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
      <section className="coupon-frame">
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

        <section className="control-panel">
          <label className="search-field">
            <span>キーワード検索</span>
            <input
              type="search"
              placeholder="商品名・ブランド名で探す"
              value={searchText}
              onChange={(event) => setSearchText(event.target.value)}
            />
          </label>

          <div className="chip-row" aria-label="カテゴリ絞り込み">
            <button
              className={`filter-chip ${selectedCategory === "" ? "is-active" : ""}`}
              type="button"
              onClick={() => setSelectedCategory("")}
            >
              すべて
            </button>
            {categories.map((category) => (
              <button
                className={`filter-chip ${selectedCategory === category ? "is-active" : ""}`}
                key={category}
                type="button"
                onClick={() => setSelectedCategory(category)}
              >
                {category}
              </button>
            ))}
          </div>
        </section>

        <div className="section-head">
          <div>
            <h2 className="section-title coupon-list-title">おすすめクーポン</h2>
          </div>
          <span className="section-count">{isLoading ? "Loading..." : `全${coupons.length}件`}</span>
        </div>

        <div className="coupon-grid">
          {coupons.map((coupon) => (
            <article
              className="coupon-card"
              key={coupon.slug}
              onClick={() => (window.location.href = `/coupons/detail?slug=${encodeURIComponent(coupon.slug)}`)}
              onKeyDown={(event) => {
                if (event.key === "Enter" || event.key === " ") {
                  event.preventDefault();
                  window.location.href = `/coupons/detail?slug=${encodeURIComponent(coupon.slug)}`;
                }
              }}
              role="button"
              tabIndex={0}
            >
              <div className="coupon-thumb-wrap">
                <img className="coupon-thumb" src={coupon.image_url} alt={coupon.title} />
                <div className="coupon-discount-badge">{coupon.discount_text}</div>
                <div className="coupon-cut coupon-cut-left" aria-hidden="true" />
                <div className="coupon-cut coupon-cut-right" aria-hidden="true" />
              </div>

              <div className="coupon-content">
                <div className="coupon-heading">
                  <div className="coupon-heading-copy">
                    <h3 className="coupon-title">{coupon.title}</h3>
                    <p className="coupon-expiry">期限: {formatDate(coupon.ends_at)}まで</p>
                  </div>
                  <button
                    aria-label="お気に入り"
                    className="coupon-favorite"
                    tabIndex={-1}
                    type="button"
                  >
                    ♡
                  </button>
                </div>

                <div className="freshness-block">
                  <div className="freshness-copy">
                    <span>{freshnessLabel(coupon.freshness_ratio)}</span>
                    <strong>{coupon.freshness_ratio}%</strong>
                  </div>
                  <div className="freshness-gauge" aria-hidden="true">
                    <div className="freshness-gauge-fill" style={{ width: `${coupon.freshness_ratio}%` }} />
                  </div>
                </div>

                <div className="coupon-card-actions">
                  <button className="coupon-use-button" tabIndex={-1} type="button">
                    クーポンを使う
                  </button>
                </div>
              </div>
            </article>
          ))}
        </div>

        {!isLoading && coupons.length === 0 ? <p className="empty-state">条件に合うクーポンが見つかりませんでした。</p> : null}

        <div className={`feedback ${feedback.kind}`} role="status" aria-live="polite">
          {feedback.message}
        </div>
      </section>
    </div>
  );
}
