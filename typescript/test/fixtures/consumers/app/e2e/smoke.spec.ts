import { expect, test } from "@playwright/test";

test("loads", async ({ page }) => {
  await page.goto("/");
  await expect(page).toHaveTitle("home");
  await expect(page.getByRole("main")).toBeVisible();
});
