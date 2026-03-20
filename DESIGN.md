# Design System Specification: The Fresh Daily Interface

## 1. Overview & Creative North Star
### Creative North Star: "The Modern Konbini Curator"
This design system moves beyond the utility of a standard coupon app to create an editorial-inspired experience that mirrors the precision and freshness of a premium Japanese convenience store. We reject the "budget app" aesthetic of cluttered grids and harsh borders. Instead, we embrace **Soft Layering** and **Asymmetric Breathing Room**. 

The system treats every digital coupon as a curated object. By utilizing high-contrast typography scales and overlapping surface elements, we create a sense of tactile depth—as if the user is flipping through a beautifully designed, high-end food magazine rather than scrolling a list.

---

## 2. Colors: Tonal Depth & Vibrancy
Our palette balances the "Store Green" (`primary`) for trust and freshness with a high-energy "Discount Orange" (`secondary`). 

### The "No-Line" Rule
**Explicit Instruction:** Do not use 1px solid borders to define sections. Layout boundaries must be achieved through background shifts.
*   Place a `surface-container-low` (#f1f1ec) element on a `surface` (#f7f7f2) background to define a zone.
*   Use `surface-container-highest` (#dcddd7) only for the most recessed decorative elements or secondary structural blocks.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of fine Japanese paper.
*   **Base:** `surface` (#f7f7f2)
*   **Elevated Content:** Nest a `surface-container-lowest` (#ffffff) card inside a `surface-container-low` (#f1f1ec) wrapper to create a soft, natural lift.

### The Glass & Gradient Rule
To prevent a "flat" appearance, apply a subtle linear gradient to primary CTAs:
*   **From:** `primary` (#00694a) **To:** `primary_dim` (#005b40) at a 135-degree angle.
*   **Glassmorphism:** For floating navigation bars or category chips, use `surface` (#f7f7f2) at 80% opacity with a `backdrop-blur` of 12px.

---

## 3. Typography: Editorial Authority
We utilize a dual-font system to balance Japanese legibility with modern editorial flair.

*   **Display & Headlines (Plus Jakarta Sans):** Used for "Hero" moments—massive discount percentages or "Good Morning" greetings. These should feel bold and intentional.
    *   *Example:* `display-lg` (3.5rem) for a "50% OFF" headline creates an immediate visual anchor.
*   **Title & Body (Be Vietnam Pro / Noto Sans JP Fallback):** Used for product names and descriptions. The high x-height ensures readability on small mobile screens.
    *   *Hierarchy Tip:* Use `title-lg` (1.375rem) for product names to give them "breathing room" against the `body-sm` (0.75rem) terms and conditions.

---

## 4. Elevation & Depth: Tonal Layering
Traditional shadows are often too "heavy" for a fresh, clean brand. We prioritize **Tonal Layering**.

*   **The Layering Principle:** Depth is achieved by stacking. A `surface-container-lowest` card sitting on a `surface-container-high` background provides all the separation needed without visual clutter.
*   **Ambient Shadows:** If a card must "float" (e.g., a high-value coupon), use a shadow with a blur of 24px and an opacity of 6%, using a tint of `on_surface` (#2d2f2c).
*   **The Ghost Border:** If a boundary is strictly required for accessibility, use `outline_variant` (#adada9) at **15% opacity**. Never use a 100% opaque border.

---

## 5. Components: The Signature Collection

### Buttons (The "Pill" Interaction)
*   **Primary:** Roundedness `full` (9999px). Background: `primary` gradient. Text: `on_primary` (#c7ffe2). 
*   **Secondary:** Roundedness `full`. Background: `secondary_container` (#ffc69a). Use for "Add to Cart" or "Save for Later."
*   **Interactions:** On press, scale the button down to 96% to provide tactile haptic feedback.

### Category Chips
*   Instead of standard boxes, use `md` (1.5rem) rounded corners. 
*   **Active State:** `tertiary_container` (#00d9fd) with `on_tertiary_container` text.
*   **Inactive State:** `surface-container-high` (#e2e3dd) to blend into the background.

### Cards & Coupons
*   **Forbid Dividers:** Do not use lines to separate product info. Use `spacing-4` (1rem) of vertical white space.
*   **The "Punch-Out" Detail:** Use a `surface` colored circle overlay on the left and right edges of a `surface-container-lowest` card to mimic a physical perforated coupon.

### Input Fields
*   **Style:** Minimalist. No bottom line. Use a `surface-container-highest` fill with `none` (0px) borders and `sm` (0.5rem) rounded corners.
*   **Error State:** Change background to `error_container` (#fb5151) at 20% opacity, rather than just changing the text color.

### Signature Component: The "Freshness Gauge"
A custom progress bar for limited-time coupons using a gradient from `secondary` (Orange) to `primary` (Green), showing the "freshness" or availability of the deal.

---

## 6. Do’s and Don’ts

### Do
*   **Do** use asymmetrical margins. A larger left margin (e.g., `spacing-8`) for headlines creates an editorial look.
*   **Do** use `tertiary` (#006576) for utility icons (Account, Settings) to keep them distinct from the `primary` shopping actions.
*   **Do** leverage the `xl` (3rem) corner radius for hero imagery to make food photography feel soft and appetizing.

### Don’t
*   **Don't** use pure black (#000000). Always use `on_surface` (#2d2f2c) for text to maintain the "off-white" softness.
*   **Don't** use standard "Drop Shadows." They muddy the "Fresh Store" aesthetic. Use tonal shifts first.
*   **Don't** cram icons. If an icon is used (Food, Drink), it must have at least `spacing-3` (0.75rem) of clear space around it.