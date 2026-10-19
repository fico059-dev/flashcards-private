type Claims = {
  roles?: string[];
  entitlements?: string[];
  packsExp?: number;
  bothExp?: number;
  osceExp?: number;
  // legacy fallback:
  cardsExp?: number;
  allExp?: number;
};

export function hasCards(claims: Claims | null | undefined): boolean {
  if (!claims) return false;
  const now = Date.now();
  const ents = claims.entitlements ?? [];
  if (ents.includes("both") || ents.includes("packs")) return true;

  const packsExp = claims.packsExp ?? claims.cardsExp ?? 0; // fallback
  const bothExp = claims.bothExp ?? claims.allExp ?? 0; // fallback
  return bothExp > now || packsExp > now;
}
