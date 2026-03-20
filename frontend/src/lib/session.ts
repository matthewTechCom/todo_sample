export type SessionUser = {
  id: number;
  email: string;
};

export type CouponListItem = {
  id: number;
  slug: string;
  title: string;
  brand_name: string;
  category: string;
  discount_text: string;
  description: string;
  image_url: string;
  starts_at: string;
  ends_at: string;
  freshness_ratio: number;
};

export type CouponDetail = CouponListItem & {
  terms_and_conditions: string;
};

const COOKIE_MAX_AGE = 60 * 60 * 24 * 7;
const TOKEN_KEY = "coupon-sample-token";
const USER_KEY = "coupon-sample-user";

const isBrowser = () => typeof document !== "undefined";

const readRawCookie = (name: string) => {
  if (!isBrowser()) return null;
  const prefix = `${name}=`;
  const value =
    document.cookie
      .split(";")
      .map((row) => row.trim())
      .find((row) => row.startsWith(prefix))
      ?.slice(prefix.length) ?? null;

  return value ? decodeURIComponent(value) : null;
};

const writeCookie = (name: string, value: string) => {
  if (!isBrowser()) return;
  document.cookie = `${name}=${encodeURIComponent(value)}; path=/; max-age=${COOKIE_MAX_AGE}; SameSite=Lax`;
};

const clearCookie = (name: string) => {
  if (!isBrowser()) return;
  document.cookie = `${name}=; path=/; max-age=0; SameSite=Lax`;
};

export const normalizeToken = (token: string | null) => {
  if (!token) return null;
  return token.startsWith("Bearer ") ? token : `Bearer ${token}`;
};

export const readToken = () => {
  const token = normalizeToken(readRawCookie(TOKEN_KEY));
  if (token && token !== readRawCookie(TOKEN_KEY)) {
    writeCookie(TOKEN_KEY, token);
  }
  return token;
};

export const readUser = () => {
  const value = readRawCookie(USER_KEY);
  if (!value) return null;

  try {
    return JSON.parse(value) as SessionUser;
  } catch {
    return null;
  }
};

export const persistSession = (token: string, user: SessionUser) => {
  const normalizedToken = normalizeToken(token);
  if (!normalizedToken) return;

  writeCookie(TOKEN_KEY, normalizedToken);
  writeCookie(USER_KEY, JSON.stringify(user));
};

export const clearSession = () => {
  clearCookie(TOKEN_KEY);
  clearCookie(USER_KEY);
};

export const parseResponse = async <T>(response: Response) => {
  const contentType = response.headers.get("content-type") ?? "";
  if (contentType.includes("application/json")) {
    return (await response.json()) as T;
  }

  return null;
};

export const extractToken = <T extends { token?: string }>(
  response: Response,
  payload: T | null,
) => {
  const headerToken = response.headers.get("Authorization");
  if (headerToken) return normalizeToken(headerToken);
  return normalizeToken(payload?.token ?? null);
};

export const authFetch = async <T>(
  apiBaseUrl: string,
  path: string,
  options: RequestInit = {},
) => {
  const headers = new Headers(options.headers ?? {});
  headers.set("Content-Type", "application/json");

  const response = await fetch(`${apiBaseUrl}${path}`, {
    ...options,
    headers,
  });

  const payload = await parseResponse<T>(response);
  return { response, payload };
};

export const apiFetch = async <T>(
  apiBaseUrl: string,
  path: string,
  options: RequestInit = {},
) => {
  const headers = new Headers(options.headers ?? {});
  headers.set("Content-Type", "application/json");

  const token = readToken();
  if (token) {
    headers.set("Authorization", token);
  }

  const response = await fetch(`${apiBaseUrl}${path}`, {
    ...options,
    headers,
  });

  const payload = await parseResponse<T>(response);
  return { response, payload };
};
