import { CheckboxInput, FeatureToggle } from "../base";

export const credits_uses_ckey: FeatureToggle = {
  name: "Auto Punctuation",
  category: "GAMEPLAY",
  description: "Automatically append a period to speech if there is no punctuation.",
  component: CheckboxInput,
};
