export type Entitlement = "packs" | "osce" | "both";
export function mapSubscriptionToEntitlement(opts: {
  subscriptionId: string;
  basePlanId?: string | null;
}): Entitlement | null {
  const {subscriptionId} = opts;
  if (subscriptionId === "cards_monthly" || subscriptionId === "cards_yearly") {
    return "packs";
  }
  if (subscriptionId === "both_monthly" || subscriptionId === "both_yearly") {
    return "both";
  }
  return null;
}
