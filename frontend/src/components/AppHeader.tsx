import { useEffect, useRef, useState, type ReactNode } from "react";

type AppHeaderMenuItem = {
  label: string;
  onClick: () => void;
  tone?: "default" | "danger";
};

type AppHeaderProps = {
  menuItems?: AppHeaderMenuItem[];
  children?: ReactNode;
};

export default function AppHeader({
  menuItems = [],
  children,
}: AppHeaderProps) {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!isMenuOpen) return;

    const handlePointerDown = (event: PointerEvent) => {
      if (!menuRef.current?.contains(event.target as Node)) {
        setIsMenuOpen(false);
      }
    };

    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        setIsMenuOpen(false);
      }
    };

    document.addEventListener("pointerdown", handlePointerDown);
    document.addEventListener("keydown", handleEscape);

    return () => {
      document.removeEventListener("pointerdown", handlePointerDown);
      document.removeEventListener("keydown", handleEscape);
    };
  }, [isMenuOpen]);

  return (
    <header className="app-header">
      <a className="app-header-brand" href="/coupons">
        <span className="app-header-brand-badge" aria-hidden="true">
          <svg className="app-header-brand-svg" viewBox="0 0 24 24">
            <path
              d="M4 10.5V20h16v-9.5M3 9l2.2-5h13.6L21 9M7 14h2.5M14.5 14H17"
              fill="none"
              stroke="currentColor"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="1.8"
            />
          </svg>
        </span>
        <h1 className="app-header-brand-title">The Fresh Daily</h1>
      </a>

      <div className="app-header-actions">
        {children}

        {menuItems.length > 0 ? (
          <div className="app-header-menu" ref={menuRef}>
            <button
              aria-expanded={isMenuOpen}
              aria-haspopup="menu"
              aria-label="メニューを開く"
              className="menu-trigger"
              type="button"
              onClick={() => setIsMenuOpen((current) => !current)}
            >
              <span aria-hidden="true" className="menu-trigger-line" />
              <span aria-hidden="true" className="menu-trigger-line" />
              <span aria-hidden="true" className="menu-trigger-line" />
            </button>

            {isMenuOpen ? (
              <div className="menu-dropdown" role="menu">
                {menuItems.map((item) => (
                  <button
                    className={`menu-item ${item.tone === "danger" ? "is-danger" : ""}`}
                    key={item.label}
                    role="menuitem"
                    type="button"
                    onClick={() => {
                      setIsMenuOpen(false);
                      item.onClick();
                    }}
                  >
                    {item.label}
                  </button>
                ))}
              </div>
            ) : null}
          </div>
        ) : null}
      </div>
    </header>
  );
}
