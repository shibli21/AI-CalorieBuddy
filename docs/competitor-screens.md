# BitePal - Competitor Screen Catalog

Reference material for building **CalorieBuddy**. Source: 158 screenshots in `mock/images/` (BitePal, an AI calorie-tracking iOS app with a raccoon mascot), analyzed screen-by-screen. Free tier = 139 screens, Pro = 16, unknown = 3.

## Empty/Loading (2)

### Launch / Splash Screen [free_screen_001.webp] (free)
- **Purpose:** App cold-start splash screen shown while the app initializes, presenting the BitePal raccoon mascot brand mark before the onboarding welcome appears.
- **UI:** Solid lavender/light-purple full-screen background; Centered black-and-pink raccoon mascot face glyph (winking eye, open mouth with pink tongue) used as the logo mark; iOS status bar (cellular, wifi, battery) at top right; Home indicator bar at bottom; No text, buttons, or controls
- **iOS:** ZStack; Color (background); Image (vector/PDF asset); LaunchScreen storyboard or SwiftUI splash View; ProgressView (optional hidden loader)
- **Data:** None displayed. Internally may load session/auth state and config before routing to onboarding or home.
- **Interactions:** No user interaction; auto-transitions after load completes (likely to the welcome/onboarding screen). Possible fade/scale animation of the mascot.

### Statistics Locked - Log More Days Empty State [pro_screen_099.webp] (free)
- **Purpose:** Empty/gated state on the Statistics tab when insufficient data exists; prompts the user to keep logging before insights unlock. (Behind the blurred mockup is the future stats layout.)
- **UI:** Blurred/greyed-out preview of the upcoming statistics screen (rings, colored insight cards in background); Progress indicator of three day-squares: first filled green with checkmark, second and third empty outlined squares; Headline 'Log 2 more days to see statistics!' (with '2 more days' in green); Subtitle 'We need data from at least 3 days to analyze your habits and provide personalized insights.'; Small green spark accents; Bottom tab bar: Home (house, grey), Stats (bar chart, active/black), Settings (gear, grey)
- **iOS:** ZStack with blurred placeholder content (.blur); HStack of progress squares (RoundedRectangle filled check + empty strokes); Text title (with AttributedString colored span) + secondary subtitle; Custom TabBar (SF Symbols house, chart.bar.fill, gearshape)
- **Data:** Days logged count (1 of 3 required), remaining days needed (2), tab selection state
- **Interactions:** Logging more days fills the squares and unlocks stats; tap tab bar to navigate; this is a non-interactive informational gate

## Onboarding / Auth (3)

### Create Account (Apple Sign-In Sheet) [pro_screen_053.webp] (free)
- **Purpose:** Account creation step at the end of onboarding, prompting the user to sign up via Apple or Google so progress is saved. Shows the native federated sign-in confirmation dialog.
- **UI:** Large bold title 'Now let's create account'; Subtitle 'Save your progress & reach your goals'; Grey raccoon mascot illustration peeking from behind dialog; Mint/green sparkle accent; Native system alert: '"BitePal" Wants to Use "google.com" to Sign In' with body 'This allows the app and website to share information about you.'; Alert buttons 'Cancel' and 'Continue'; Black pill button 'Continue with Apple' with Apple logo; Outlined pill button 'Continue with Google' with Google logo
- **iOS:** NavigationStack; VStack; Text (large title weight); Image (mascot asset); SignInWithAppleButton / ASAuthorizationController; ASWebAuthenticationSession (Google federated sign-in); Capsule-styled Button; system UIAlertController
- **Data:** User auth identity (Apple ID credential / Google OAuth token), display name, email; account creation request.
- **Interactions:** Tap 'Continue with Apple' triggers Sign in with Apple sheet; tap 'Continue with Google' triggers federated web auth which produces the system 'Wants to Use google.com' alert; tap 'Continue' proceeds to Google account chooser; tap 'Cancel' dismisses.

### Google Account Chooser (Web Auth) [pro_screen_054.webp] (free)
- **Purpose:** Google federated sign-in web page (localized to Filipino) where the user picks which Google account to continue into BitePal with.
- **UI:** Safari-style web sheet chrome: 'Cancel', address bar 'accounts.google.com', reader/refresh icons; Google 'G' logo with 'Mag-sign in sa Google'; Heading 'Pumili ng account' (Choose an account); Subtext 'upang magpatuloy sa Bitepal'; Account row: avatar 'S', 'Screensdesign', 'screensdesigntest@gmail.com'; Row 'Gumamit ng isa pang account' (Use another account); Language selector 'Filipino' dropdown; Footer links: Tulong / Pagkapribado / Mga Kataga; Bottom web nav arrows and share icon
- **iOS:** ASWebAuthenticationSession (system web sheet, not custom UI); SFSafariViewController-style presentation
- **Data:** Google account list, selected account email; OAuth continuation to Bitepal client.
- **Interactions:** Tap an account row to authenticate; tap 'Use another account' to add an account; tap 'Cancel' to abort; change language via dropdown.

### Google Consent / Permissions (Web Auth) [pro_screen_055.webp] (free)
- **Purpose:** Google OAuth consent screen confirming which profile data Bitepal will receive before completing sign-in.
- **UI:** Web sheet chrome: 'Cancel', 'accounts.google.com'; Google 'G' + 'Sign in with Google'; Heading 'Sign in to Bitepal'; Account chip 'screensdesigntest@gmail.com' with avatar and chevron; Section 'Google will allow Bitepal to access this info about you'; Permission row: profile icon, 'Screensdesign', 'Name and profile picture'; Permission row: envelope icon, 'screensdesigntest@gmail.com', 'Email address'; Legal paragraph referencing Bitepal's Privacy Policy and Terms of Service, 'Google Account' link; 'Learn more about Sign in with Google' link; Two pill buttons: 'Cancel' and 'Continue'; Footer: 'English (United States)' dropdown, Help, Privacy, Terms
- **iOS:** ASWebAuthenticationSession (system web sheet); OAuth provider UI (no custom SwiftUI)
- **Data:** OAuth scopes (name, profile picture, email), consent grant returning auth code/token to app.
- **Interactions:** Tap 'Continue' grants scopes and returns to app authenticated; tap 'Cancel' aborts; tap account chip to switch account; tap policy/learn-more links.

## Auth (1)

### Create Account (Apple / Google sign-in) [pro_screen_052.webp] (free)
- **Purpose:** Post-purchase account creation screen to persist progress and sync the subscription, offering Sign in with Apple and Google.
- **UI:** Light lavender background; Headline 'Now let's create account'; Subtitle 'Save your progress & reach your goals'; Blue sparkle accent; Centered grey raccoon mascot making a heart gesture with both paws; Primary dark pill button '(Apple logo) Continue with Apple'; Secondary outlined pill button '(Google logo) Continue with Google'; Home indicator at bottom
- **iOS:** VStack; Image (mascot asset); SignInWithAppleButton; Custom outlined Capsule Button for Google sign-in; Text title/subtitle
- **Data:** auth provider selection (Apple/Google), credential/token to create account, link to active subscription/entitlement and onboarding profile
- **Interactions:** Tap 'Continue with Apple' launches ASAuthorizationController (Sign in with Apple); tap 'Continue with Google' launches Google OAuth flow; on success creates account and enters the main app

## Onboarding (55)

### Welcome Screen with ATT Tracking Prompt [free_screen_002.webp] (free)
- **Purpose:** First onboarding/welcome screen ('Reach your weight goals') shown with the iOS App Tracking Transparency (ATT) system permission dialog overlaid on top.
- **UI:** Background collage: granola/blueberry bowl labeled '310 kcal', floating pink heart emojis, raccoon mascot in a circular badge, handwritten 'With cute raccoon' note with arrow, a blue circular '+' add badge, and a green '16:8' fasting ring; Partially visible bold headline 'Reach ... goals'; iOS ATT alert: title 'Allow "BitePal" to track your activity across other companies' apps and websites?'; Alert body: 'This identifier is used for analytics purposes to measure performance of our marketing activities.'; Two alert buttons: 'Ask App Not to Track' and 'Allow'; Black pill 'Get started' button; 'I already have an account' text link; Fine print: 'By continuing you're accepting our Terms of Use and Privacy Notice'
- **iOS:** ZStack with layered Image collage; ATTrackingManager.requestTrackingAuthorization (system alert, not custom); Text (headline); Button (filled capsule 'Get started'); Button (plain text 'I already have an account'); AttributedString / Link for Terms & Privacy
- **Data:** ATT authorization status; analytics/marketing attribution identifier (IDFA). Welcome content is static marketing copy.
- **Interactions:** User taps 'Allow' or 'Ask App Not to Track' to dismiss the system alert; then 'Get started' launches onboarding carousel, or 'I already have an account' routes to sign-in. Tappable legal links.

### Welcome / Value Proposition Screen [free_screen_003.webp] (free)
- **Purpose:** Main welcome landing screen positioning the app's core promise of weight-goal achievement with playful raccoon branding; entry point into onboarding or sign-in.
- **UI:** Light gradient background (peach to white); Decorative collage: granola/blueberry bowl with '310 kcal' tag, floating pink heart emojis, raccoon mascot in red-bordered circular badge, handwritten 'With cute raccoon' label with curved arrow, blue circular '+' badge (top-left), green '16:8' progress ring (right); Large bold black headline 'Reach your weight goals' across 4 lines; Black capsule 'Get started' button; 'I already have an account' bold text link; Footer fine print 'By continuing you're accepting our Terms of Use and Privacy Notice'
- **iOS:** ZStack; Image (decorative assets); Text (large title, .bold, custom rounded display font); Button (filled black Capsule); Button (text link); LinearGradient background; Link / AttributedString for legal text
- **Data:** Static marketing copy and decorative assets only. No live user data.
- **Interactions:** 'Get started' begins the onboarding carousel; 'I already have an account' navigates to login; tap legal links for Terms/Privacy. Possible subtle floating/parallax animation of collage elements.

### Onboarding Carousel - Track Calories [free_screen_004.webp] (free)
- **Purpose:** First slide (page 1 of 5) of the feature-tour carousel demonstrating AI photo-based calorie tracking.
- **UI:** Back chevron button (top-left, circular grey); Page indicator: 5 dots with first active (â—â—‹â—‹â—‹â—‹); Large rounded card with a green-tinted healthy plate photo (avocado, egg, sweet potato, greens, quinoa); Floating white pill labels with detected foods: 'Sweet potato 120 kcal', 'Avocado 100 kcal', 'Eggs 80 kcal' (each with kcal in grey); White circular dots overlaid on food items (AI detection points); Cute raccoon mascot illustration (excited, hands on cheeks) overlapping the card; Bold headline 'Track calories'; Subtitle 'Just snap a photo and let AI do the rest'; Black capsule 'Next >' button
- **iOS:** TabView(.page) or custom PagingScrollView; PageControl / custom dot indicator; ZStack for layered card + floating labels; RoundedRectangle / Image with .clipShape; Capsule labels (Text); Image (mascot); Button (back chevron in Circle); Button (filled black Capsule 'Next')
- **Data:** Static demo content (sample foods and kcal values). Illustrates the AI food-recognition data shape: food name + estimated calories + bounding/detection points.
- **Interactions:** Swipe horizontally or tap 'Next' to advance carousel; tap back chevron to return; page dots update on swipe.

### Onboarding Carousel - Stay Hydrated (Water Tracking) [free_screen_005.webp] (free)
- **Purpose:** Carousel slide (page 2 of 5) introducing the water-intake tracking feature.
- **UI:** Back chevron (top-left); Page indicator dots with 2nd active (â—‹â—â—‹â—‹â—‹); Rounded blue card with raccoon mascot wearing red snorkel/dive mask and pink duck floatie on a wavy blue water background; 'Water' label; Large value '250 ml'; Circular '+' add button with a blue partial progress ring around it; Row of 5 glass icons; first glass filled blue, remaining 4 empty (intake progress); Bold headline 'Stay hydrated'; Subtitle 'Easily track your water and hit your goals'; Black capsule 'Next >' button
- **iOS:** TabView(.page); RoundedRectangle card; Image (mascot); Text (value + unit); Button with Circle + Circle/trim stroke progress ring; HStack of glass Image/Shape icons; Button (filled black Capsule 'Next'); Back chevron Button
- **Data:** Water intake amount (250 ml), number of glasses consumed vs daily goal (1 of 5), per-glass volume. Demo values in onboarding.
- **Interactions:** Tap '+' to add a glass / increment water; swipe or tap 'Next' to advance; back chevron to go back; progress ring and glasses fill as water is added.

### Onboarding Carousel - See Results (Weight Progress Chart) [free_screen_007.webp] (free)
- **Purpose:** Carousel slide (page 4 of 5) showcasing weight-progress tracking and trend visualization.
- **UI:** Back chevron (top-left); Page indicator dots with 4th active (â—‹â—‹â—‹â—â—‹); Card with heart-eyed raccoon mascot on a pastel rainbow/sparkle background; 'Weight' stat '76 kg'; 'Progress' stat '-6 kg'; Multi-colored line chart (redâ†’orangeâ†’yellowâ†’green gradient) with circular node markers trending downward; X-axis date labels: 'Jun 3', 'Jun 17', 'Jul 1', 'Jul 15', 'Jul 24', 'Jul 31' (Jul 31 bold/selected with caret marker); Dashed vertical gridlines; Bold headline 'See results'; Subtitle 'Watch your progress and celebrate every win'; Black capsule 'Next >' button
- **iOS:** TabView(.page); Swift Charts (LineMark + PointMark with gradient ForegroundStyle); Text stat blocks (HStack); RoundedRectangle card + Image (mascot); AxisMarks for dates; Button (filled black Capsule 'Next'); Back chevron Button
- **Data:** Current weight (76 kg), total progress delta (-6 kg), time-series of weight entries with dates (Jun 3â€“Jul 31). Demo data in onboarding.
- **Interactions:** Swipe or tap 'Next' to advance; back chevron returns; selectable/scrubbing data points on the chart with highlighted date.

### Onboarding Carousel - Feel the Love (Macro Balance / Mascot Reaction) [free_screen_008.webp] (free)
- **Purpose:** Final carousel slide (page 5 of 5) reinforcing the encouraging-buddy concept and showing macro breakdown of a balanced meal.
- **UI:** Page indicator dots with last active (â—‹â—‹â—‹â—‹â—); White card overlaying a food photo: heading 'Yesss! That's what a well-balanced plate looks like!'; Segmented macro bar (yellow, blue, green segments); Macro stats with colored dots: 'Carbs 75 g', 'Fats 28 g', 'Proteins 24 g'; Healthy plate photo (avocado, egg, greens, chickpeas) with small raccoon mascot badge in the corner; Bold headline 'Feel the love'; Subtitle 'Your virtual buddy supports your healthy choices'; Black capsule 'Next >' button
- **iOS:** TabView(.page); RoundedRectangle card; Custom segmented macro bar (HStack of colored Capsules); HStack stat rows with Circle color dots + Text; Image (food photo + mascot badge); Text (title/subtitle); Button (filled black Capsule 'Next')
- **Data:** Macro breakdown for a sample meal: Carbs 75 g, Fats 28 g, Proteins 24 g, with proportional bar. Encouragement copy keyed to balanced-meal detection. Demo data.
- **Interactions:** Tap 'Next' to finish the carousel and proceed to onboarding questions/sign-up; final page dot active. Possible mascot reaction animation.

### Onboarding Question - How Did You Hear About Us [pro_screen_001.webp] (free)
- **Purpose:** Attribution survey question collecting marketing-source data during onboarding (single-select).
- **UI:** Back chevron (top-left); Bold two-line heading 'How did you hear about us?'; Six selectable option rows, each a white rounded card with a brand icon + label: 'From influencer' (face emoji), 'Instagram' (IG gradient icon), 'TikTok' (TikTok logo), 'Youtube' (YouTube logo), 'App Store search' (App Store icon) â€” currently selected/highlighted with green border and light-green fill, 'Friends/family' (face emoji); Black capsule 'Next >' button at bottom
- **iOS:** ScrollView / VStack of selectable rows; Button or custom Toggle rows styled as RoundedRectangle cards with stroke on selection; HStack (icon Image + Text); @State selectedOption binding; Back chevron Button; Button (filled black Capsule 'Next')
- **Data:** Acquisition channel selection (one of: influencer, Instagram, TikTok, YouTube, App Store search, friends/family) stored for analytics/attribution.
- **Interactions:** Tap a row to single-select (green highlight); tap 'Next' to proceed; back chevron to return. Note: despite the 'pro_' filename, no paywall/crown/lock elements are present â€” this is a free onboarding survey screen.

### Onboarding Question - What Is Your Main Goal [pro_screen_002.webp] (free)
- **Purpose:** Goal-selection onboarding question used to personalize the user's calorie/weight plan (single-select).
- **UI:** Back chevron (top-left); Bold two-line heading 'What is your main goal?'; Three selectable option rows, each white rounded card with a colored icon + label: 'Lose weight' (green down-arrow + bar-chart icon) â€” selected/highlighted with green border, light-green fill, and a radio circle on the right; 'Maintain weight' (yellow scale icon); 'Gain weight' (red kettlebell icon); Black capsule 'Next >' button at bottom
- **iOS:** VStack of selectable rows; Custom radio-style selectable Button/RoundedRectangle cards with stroke + Circle indicator on selection; HStack (icon Image + Text); @State selectedGoal binding; Back chevron Button; Button (filled black Capsule 'Next')
- **Data:** Primary goal selection (lose / maintain / gain weight) â€” drives target calorie budget, macro targets, and projected weight plan.
- **Interactions:** Tap a row to single-select (green highlight + radio fill); tap 'Next' to continue onboarding; back chevron to return. Note: despite the 'pro_' filename, there is no paywall/crown/lock framing â€” this is a free onboarding question screen.

### Additional Goals (Multi-select) [pro_screen_003.webp] (free)
- **Purpose:** Capture secondary motivation/goals during onboarding so the program can be personalized (energy, gut health, wellbeing, self-image, sport, stress, nutrition education).
- **UI:** Back chevron (top-left); Title 'Any additional goals?'; Selectable cards each with emoji icon + label and a right-side circular check indicator; Card: broccoli icon 'Build healthy relationship with food' (unselected, grey circle); Card: red heart 'Improve overall wellbeing' (unselected); Card: green battery 'Boost daily energy' (SELECTED - green border, light-green fill, green filled checkmark); Card: stomach icon 'Improve gut health' (SELECTED - green border + green check); Card: face 'Feel better about myself' (unselected); Card: running shoe 'Improve sport performance' (unselected); Card: 'Reduce stress' (unselected, partially scrolled); Card: 'Learn more about nutrition' (unselected, cut off at bottom edge); Dark pill 'Next >' button
- **iOS:** NavigationStack with custom back button; ScrollView + LazyVStack of selectable rows; Custom toggle/selectable Button with RoundedRectangle + overlay stroke for selected state; Image (SF Symbols or emoji/asset) leading icon; Circle + Image(systemName: checkmark.circle.fill) trailing indicator; Capsule primary CTA Button
- **Data:** List of goal options (id, emoji/icon, title); user's multi-select set of chosen goal IDs persisted to onboarding profile
- **Interactions:** Tap card to toggle selection (multi-select, animated border/fill change); scroll list vertically; Back to previous step; Next advances onboarding

### Long-term Results Comparison [pro_screen_004.webp] (free)
- **Purpose:** Persuasion/value-prop screen showing BitePal sustains weight loss vs other apps (weight rebound), with a social-proof statistic.
- **UI:** Light green gradient background with green sparkle/star accents; Back chevron; Title 'BitePal provides long-term results'; White rounded chart card; Green solid curved line labeled 'BitePal' (declining/sustained) with circular end markers; Red dashed curved line labeled 'Other apps' (dips then rebounds upward) with red end dot; Axis labels 'Your weight' and 'Time'; Stat pill: green up-arrow badge + '76% BitePal users maintain their weight loss over 6 months'; Dark pill 'Next >' button
- **iOS:** ZStack with LinearGradient background; Decorative star Images; Card: RoundedRectangle white surface with shadow; Swift Charts LineMark (or custom Path/Shape) for two comparison curves with PointMark end dots; Text annotations / overlay labels; Capsule callout with HStack icon+Text; Capsule CTA Button
- **Data:** Two illustrative weight-over-time series (BitePal vs other apps) â€” static marketing data; retention stat string (76% / 6 months)
- **Interactions:** Read-only persuasion screen; Back; Next advances

### Calorie Counting Experience (Single-select) [pro_screen_005.webp] (free)
- **Purpose:** Gauge user's prior experience with calorie counting to tailor difficulty/education.
- **UI:** Back chevron; Title 'Have you tried calorie counting before?'; Option card: fire emoji 'I'm new to calorie counting' (SELECTED - green border + light-green fill); Option card: face emoji 'I've tried it before but quit' (white, unselected); Option card: calculator emoji 'I'm currently counting' (white, unselected); Dark pill 'Next >' button
- **iOS:** NavigationStack + custom back button; VStack of selectable Buttons (single-select radio behavior); RoundedRectangle cards with conditional stroke/fill for selection; Leading emoji/Image + Text label; Capsule CTA Button
- **Data:** Enum of experience levels (new / tried-and-quit / currently-counting); single selected value stored in onboarding profile
- **Interactions:** Tap a card to select (single-select, deselects others); Back; Next advances

### How BitePal Works (Feature Cards) [pro_screen_006.webp] (free)
- **Purpose:** Explain the app's core value with three scattered/tilted feature cards: photo logging, daily tracking, and virtual pet support.
- **UI:** Light blue/lavender background; Back chevron; Title 'Why BitePal's unique approach works'; Blue tilted card: photo of pizza with camera scan corner brackets, caption 'Just take a photo of your food'; Dark/grey tilted card: red calorie ring + 'Total 680 KCAL' + multicolor macro bar, caption 'Track your daily progress'; Red tilted card: 'Love it!' speech tag + grey raccoon mascot with heart-eyes, caption 'Get support from your virtual pet'; Dark pill 'Let's go >' button
- **iOS:** ZStack collage of RoundedRectangle cards with rotationEffect and shadows; Image (food photo) with overlaid scan-corner Shapes; Mini calorie ring via Circle().trim + macro ProgressView/Capsule segments; Mascot Image asset + speech-bubble Capsule; Capsule CTA Button
- **Data:** Static feature-illustration content; sample calorie value (680 kcal) and macro split for the demo card
- **Interactions:** Read-only educational screen; Back; 'Let's go' advances onboarding

### Meet Your Virtual Pet (Intro / Loading) [pro_screen_009.webp] (free)
- **Purpose:** Transition/teaser screen introducing the gamified virtual-pet feature before the reveal; appears mid-animation (faded waving-hand emojis).
- **UI:** Back/status bar; Two faded grey waving-hand emoji graphics (mid-animation placeholders); Large title 'Let's meet your virtual pet!'; Stat callout pill: '5x' + 'Gamification makes habits stick for up 5x longer'; No visible primary button (likely auto-advancing/transition state)
- **iOS:** VStack centered layout; Animated Image/emoji with opacity transitions; Bold Text title; Capsule stat callout with HStack (large number Text + description Text); Likely TimelineView/withAnimation transition or onAppear auto-advance
- **Data:** Static teaser copy + gamification stat (5x); transitional state
- **Interactions:** Transitional/animated screen; likely auto-advances or swipes to the reveal; Back available

### Open the Trash (Pet Reveal Teaser) [pro_screen_010.webp] (free)
- **Purpose:** Playful interactive reveal step â€” prompt user to open a trash can to discover the raccoon mascot hiding inside.
- **UI:** Back chevron; Title 'Open to see who is there'; Large illustration: teal/mint trash can with raccoon tail sticking out, green bottle, bitten red apple, fish bones, brick-wall backdrop blocks; Dark pill 'Open' button
- **iOS:** VStack layout; Large vector Image illustration (asset); Capsule CTA Button labeled 'Open' (triggers reveal animation); Possibly tap-on-illustration gesture
- **Data:** Static illustration; no user data captured
- **Interactions:** Tap 'Open' (or the can) to trigger mascot reveal animation -> next screen; Back available

### Raccoon Pet Reveal [pro_screen_011.webp] (free)
- **Purpose:** Reveal/confirm the raccoon mascot as the user's virtual pet, completing the playful reveal sequence.
- **UI:** Back chevron; Title 'This raccoon is now your virtual pet'; Large grey raccoon mascot illustration (happy, paws together); Scattered food/trash confetti illustrations (red fish bones, yellow banana, green pickle, mint card, squiggles, dots); Dark pill 'Next >' button
- **iOS:** VStack layout; Large mascot Image asset (possibly Lottie/animated); Decorative confetti Images scattered via ZStack; Capsule CTA Button
- **Data:** Assigned/default pet character (raccoon) stored on profile
- **Interactions:** Reveal animation on appear; Back; Next advances to naming step

### Name Your Raccoon [pro_screen_012.webp] (free)
- **Purpose:** Let the user name their virtual pet to deepen attachment/gamification; defaulted to 'Rebel'.
- **UI:** Back chevron; Peeking raccoon mascot illustration in top-right corner; Caption label 'Name your raccoon'; Large editable name text 'Rebel' (current/default value, centered); Small circular edit (pencil) button at bottom-left; Dark pill 'Next >' button at bottom-right
- **iOS:** VStack layout; TextField (large centered) bound to pet name, with placeholder/default 'Rebel'; Mascot Image in corner; Circle Button with pencil SF Symbol (focus/edit name); Capsule CTA Button; Keyboard avoidance
- **Data:** Pet name String (default 'Rebel') persisted to user's pet profile
- **Interactions:** Tap name or pencil to edit via keyboard; Back; Next saves name and continues onboarding

### We'll Support You to Keep Logging (Reminders Intro) [pro_screen_013.webp] (free)
- **Purpose:** Onboarding interstitial that sells the value of notification reminders for consistent meal logging, leading into the reminder setup step.
- **UI:** Back chevron (top-left); Large bold headline 'We'll support you to keep logging'; Decorative red sparkle/star accents; Mock push-notification card with raccoon app icon, heart rating 'â™¥ ðŸ¤ ðŸ¤ ðŸ¤ (1 left)' and body text 'Don't forget to snap your meal ðŸ±'; Large grey raccoon mascot illustration sitting on a multi-color rainbow arc (red/orange/yellow/green/blue); Black pill primary CTA 'Set up reminders >'; Home indicator bar
- **iOS:** NavigationStack with custom back button (Image systemName chevron.left); ScrollView / VStack; Text with custom rounded heavy font; Custom notification preview Card (RoundedRectangle + HStack + Image); Image (mascot + rainbow asset); Capsule Button (black) for CTA; SafeAreaInset for bottom button
- **Data:** Static marketing copy; mock notification preview content. No user data required.
- **Interactions:** Tap 'Set up reminders' advances to reminder-timing selection (screen 014); back chevron returns to previous onboarding step.

### When Would You Like to Receive Reminders [pro_screen_014.webp] (free)
- **Purpose:** Lets the user pick when reminder notifications are sent, configuring notification preferences during onboarding.
- **UI:** Back chevron; Headline 'When would you like to receive reminders'; Blue sparkle accents; Selectable option row 'In the morning' with sun emoji, green selected border/fill and green check circle; Option row 'Before all meals' with crossed fork/knife emoji, unselected grey radio; Option row 'When pet is hungry' with red heart emoji, unselected grey radio; Tip pill (cream/yellow) with lightbulb: 'Reminders build healthy eating habits 2x faster'; Text link 'Set up later'; Black pill primary CTA 'Next >'; Home indicator
- **iOS:** NavigationStack + chevron back; VStack of selectable RoundedRectangle option rows (HStack: emoji + Text + selection indicator); Custom radio/checkmark (Image systemName checkmark.circle.fill, green tint); Info banner Capsule/RoundedRectangle with Label; Plain text Button 'Set up later'; Capsule Button 'Next'
- **Data:** Reminder timing preference (enum: morning / before meals / pet hungry); selected value persisted to user profile.
- **Interactions:** Tap a row toggles single selection (radio behavior); 'Next' triggers OS notification permission prompt (see screen 015); 'Set up later' skips.

### Notification Permission Prompt (System Alert) [pro_screen_015.webp] (free)
- **Purpose:** Native iOS push-notification authorization request triggered after choosing reminder timing.
- **UI:** Dimmed/blurred reminder screen behind (still shows 'In the morning' selected); System alert title '"BitePal" Would Like to Send You Notifications'; Body text 'Notifications may include alerts, sounds, and icon badges. These can be configured in Settings.'; Two system buttons: 'Don't Allow' (left) and 'Allow' (right, blue); Dimmed 'Next' button and 'Set up later' below
- **iOS:** UNUserNotificationCenter.requestAuthorization(options:) which presents the native system UIAlertController â€” not a custom view; Underlying screen rendered with .blur / dimming overlay
- **Data:** OS notification authorization status (granted/denied); no app data.
- **Interactions:** 'Allow' grants notification permission and proceeds; 'Don't Allow' denies; either dismisses alert and continues onboarding.

### Now Let's Talk About Your Eating Habits (Section Intro) [pro_screen_016.webp] (free)
- **Purpose:** Transition/section-intro screen that introduces the eating-habits questionnaire portion of onboarding.
- **UI:** Back chevron; Headline 'Now let's talk about your eating habits'; Mascot raccoon illustration (eyes closed, smiling) with two thought bubbles containing a yellow apple and a red drumstick; Decorative blue and green question marks and a yellow sparkle; Black pill primary CTA 'Let's go'; Light lavender background; Home indicator
- **iOS:** NavigationStack + chevron back; VStack; Text heavy rounded headline; Image (mascot + thought-bubble illustration asset); Capsule Button 'Let's go'
- **Data:** None; static transitional content.
- **Interactions:** Tap 'Let's go' starts the chat-style habits questionnaire (screen 017).

### How Many Meals Per Day (Meal Count Picker) [pro_screen_017.webp] (free)
- **Purpose:** Collects how many meals per day the user typically eats via a vertical number picker, framed as a chat question.
- **UI:** Back chevron; Green segmented progress bar (early progress); Raccoon avatar bubble + chat bubble question 'How many meals per day do you usually have?'; Vertical scroll/wheel number picker showing faded '1', bold selected '2', faded '3', '4'; Static label 'meals' to the right of the selected number; Black pill CTA 'Next >'; Home indicator
- **iOS:** NavigationStack + chevron back; Custom ProgressView / segmented progress bar; Chat bubble row (HStack: avatar Image + RoundedRectangle Text); Picker with .wheel style (or custom scroll snapping List) for the number; Static Text 'meals'; Capsule Button 'Next'
- **Data:** Meals-per-day integer (1-4+) saved to user nutrition profile.
- **Interactions:** Scroll/spin picker to choose meal count; 'Next' saves and advances to eating-window question (screen 018).

### Between What Hours Do You Eat (Eating Window Picker) [pro_screen_018.webp] (free)
- **Purpose:** Captures the user's daily eating window (start and finish times) to compute the eating/fasting window, feeding the intermittent-fasting feature.
- **UI:** Back chevron; Green progress bar; Chat bubble question 'Between what hours do you eat?'; Two labeled time wheel pickers: 'Start' column (faded 7:00am / 7:30am, bold selected 8:00am, faded 8:30am / 9:00am) and 'Finish' column (faded 5:00pm / 5:30pm, bold selected 6:00pm, faded 6:30pm / 7:00pm); Result card (white) 'Eating window: 10 hours' with fork/knife icon and subtext 'Eating within an 8-10 hour window may support overall health.'; Black pill CTA 'Next >'; Home indicator
- **iOS:** NavigationStack + chevron back; ProgressView; Chat bubble (avatar + Text); Two .wheel-style Pickers (or DatePicker .wheel hourAndMinute) side by side in an HStack with 'Start'/'Finish' headers; Computed result Card (RoundedRectangle + Label); Capsule Button 'Next'
- **Data:** Eating window start time, finish time; derived eating-window duration (hours) and complementary fasting window. Persisted to fasting profile.
- **Interactions:** Spin start/finish wheels; window duration recalculates live in the card; 'Next' advances to fasting result (screen 019).

### Where Do You Usually Eat (Eating Location) [pro_screen_020.webp] (free)
- **Purpose:** Asks where the user typically eats to personalize logging/recipe suggestions, chat-style single-select question.
- **UI:** Back chevron; Green progress bar; Chat bubble question 'Where do you usually eat?'; Single-select option row 'Cook at home' with pot emoji, green selected border + green check; Option row 'Eat out' with storefront emoji, unselected grey radio; Option row 'Order delivery' with takeout/bag emoji, unselected grey radio; Black pill CTA 'Next >'; Home indicator
- **iOS:** NavigationStack + chevron back; ProgressView; Chat bubble (avatar + Text); VStack of selectable RoundedRectangle rows (HStack: emoji + Text + checkmark.circle.fill); Capsule Button 'Next'
- **Data:** Eating location preference (enum: cook at home / eat out / order delivery) saved to profile.
- **Interactions:** Tap a row to single-select; 'Next' advances to diet-type question (screen 021).

### What Type of Diet Do You Prefer (Diet Preference) [pro_screen_021.webp] (free)
- **Purpose:** Collects the user's preferred diet type to tailor calorie/macro targets and recipe recommendations.
- **UI:** Back chevron; Green progress bar (further along); Chat bubble question 'What type of diet do you prefer?'; Single-select list of option rows each with emoji + label: 'Balanced' (selected, green border + balance/scale icon), 'Vegetarian', 'Vegan', 'Paleo', 'Ketogenic', 'High protein', 'Low carb'; Black pill CTA 'Next >'; Home indicator
- **iOS:** NavigationStack + chevron back; ProgressView; Chat bubble (avatar + Text); ScrollView + VStack of selectable RoundedRectangle rows (HStack: emoji + Text + selection state, green border on selected); Capsule Button 'Next'
- **Data:** Diet type preference (enum: balanced / vegetarian / vegan / paleo / ketogenic / high protein / low carb) saved to nutrition profile.
- **Interactions:** Tap a row to single-select (Balanced default); 'Next' advances to allergies/restrictions (screen 022).

### Food Restrictions or Allergies (Multi-Select Chips) [pro_screen_022.webp] (free)
- **Purpose:** Captures dietary restrictions and allergies (multi-select) so logging and recommendations exclude/flag those foods.
- **UI:** Back chevron; Green progress bar (near complete); Chat bubble question 'Do you have any food restrictions or allergies?'; Multi-select chip/tag grid: 'All meat', 'Animal products', 'Citrus fruits', 'Dairy' (selected, red dot + red outline), 'Eggs', 'Fish', 'Gluten' (selected, red dot + red outline), 'Nuts', 'Red meat', 'Seafood', 'Seeds', 'Shellfish', 'Soy', and a '+' add-custom chip; Black pill CTA 'Next >'; Home indicator
- **iOS:** NavigationStack + chevron back; ProgressView; Chat bubble (avatar + Text); Flow/wrap layout of toggleable chips (custom FlowLayout or LazyVGrid of Capsule/RoundedRectangle Buttons; selected chips show red dot + red border); '+' chip to add a custom restriction; Capsule Button 'Next'
- **Data:** Set of selected restrictions/allergies (multi-select array, e.g. [Dairy, Gluten]) plus optional custom entries; saved to profile.
- **Interactions:** Tap chips to toggle multiple selections; '+' opens add-custom-restriction input; 'Next' completes this onboarding step.

### Onboarding - Water Intake Question [pro_screen_023.webp] (free)
- **Purpose:** Single-select onboarding question gauging the user's hydration habits to personalize hydration/water recommendations.
- **UI:** Back chevron (top-left); Near-complete green linear progress bar; Raccoon mascot avatar in blue circle; Chat-bubble question card: 'Do you think you drink enough water?'; Option row 'Yes' (selected: green border + light-green fill, blue cup icon, green check); Option row 'No' (white, glass icon, red x); Option row 'Not sure' (white, confused-face icon with red '?'); Dark pill 'Next >' button
- **iOS:** NavigationStack; Button (chevron back); ProgressView (linear, green tint); HStack with Circle avatar + speech-bubble card; VStack of selectable RoundedRectangle cards; Image/emoji for icons; SF Symbols checkmark/xmark; Capsule primary Button
- **Data:** Hydration self-assessment enum {yes, no, notSure}; onboarding progress step index
- **Interactions:** Tap a card to single-select (green highlight + check); tap Next to advance; back chevron returns to previous step

### Onboarding - Water Benefits Info [pro_screen_024.webp] (free)
- **Purpose:** Educational/value interstitial reinforcing the benefit of water tracking before continuing onboarding.
- **UI:** Back chevron (top-left); Light-blue gradient background; Hero illustration: row of water glasses (some filled blue) with a glass being filled and splash droplets; Bold headline 'Water boosts fat burn, energy, and focus'; Subtext 'Water helps your body function at its best - it supports digestion, boosts energy, and keeps your mind clear.'; Dark pill 'Let's go' button
- **iOS:** ZStack with LinearGradient background; Image (hero illustration, possibly Lottie/animation); VStack with Text (large bold title) + Text (secondary caption); Capsule Button ('Let's go'); Back Button (chevron)
- **Data:** Static educational content; no user input
- **Interactions:** Tap 'Let's go' to continue; back chevron returns; likely subtle animated water-fill on entry

### Onboarding - Medical Disclaimer [pro_screen_025.webp] (free)
- **Purpose:** Legal/medical disclaimer sheet clarifying the app gives AI-backed recommendations, not medical advice.
- **UI:** Dark slate dimmed background behind a white modal sheet (grabber handle at top); Back chevron; Heart-with-leaves illustration (red heart + green leaves + motion ticks); Title 'Guiding you with care'; Body paragraph: 'BitePal provides eating recommendations backed by AI technology. However, our app is not a substitute for professional medical advice.'; Second paragraph about consulting a healthcare professional and learning about limitations; Divider line; Link text 'Learn about sources we use.'; Dark pill 'Got it!' button
- **iOS:** Sheet / presentationDetents modal with grabber; Image (heart+leaves illustration); VStack of Text blocks; Divider; Link / Button (underlined text link); Capsule Button ('Got it!')
- **Data:** Static legal disclaimer text; link to sources page
- **Interactions:** Tap 'Got it!' to dismiss/accept; tap 'sources we use' link to open sources; back chevron / swipe-down to dismiss sheet

### Onboarding - Eating Habit Goals (Multi-select) [pro_screen_026.webp] (free)
- **Purpose:** Multi-select question capturing which eating habits the user wants to change, to tailor goals/coaching.
- **UI:** Back chevron; Fully complete green progress bar; Raccoon mascot avatar + chat bubble 'What would you like to change in your eating habits?'; Selectable rows with emoji icons and right-side circular checkboxes:; 'Reduce sugar intake' (selected, green border + green filled check); 'Eat less junk food' (donut icon, unselected grey ring); 'Stop binge eating' (popcorn icon, selected green check); 'Eat more greens & veggies' (broccoli, unselected); 'Stop stress overeating' (face, unselected); 'Cook at home more often' (pot, unselected); 'Reduce salt intake' (salt shaker, unselected, partially below fold); Dark pill 'Next >' button (floating over list)
- **iOS:** ScrollView + LazyVStack of toggle cards; ProgressView (linear); Circle avatar + speech bubble; Multi-select rows using Button toggling a Set<Goal>; Trailing checkmark Circle (filled when selected); Capsule primary Button
- **Data:** Set of selected eating-habit goal enums (reduceSugar, lessJunk, stopBinge, moreGreens, stopStressEating, cookHome, reduceSalt)
- **Interactions:** Tap rows to toggle multiple selections; scroll list; tap Next to advance

### Onboarding - Goal Confirmation (Mascot Celebration) [pro_screen_027.webp] (free)
- **Purpose:** Encouraging transition screen confirming goals were captured and prompting the user to set up their goal.
- **UI:** Back chevron; Soft pink gradient background; Bold headline 'Got it! We'll help you to reach your goals'; Large grey raccoon mascot with heart-shaped eyes, praying/hopeful pose; Decorative red hearts and a yellow sparkle; Dark pill 'Set up your goal' button
- **iOS:** ZStack with LinearGradient (pink); Text (large bold headline); Image / Lottie mascot animation; Decorative Image hearts/sparkle; Capsule Button ('Set up your goal'); Back Button
- **Data:** No input; transition acknowledging prior selections
- **Interactions:** Tap 'Set up your goal' to continue; back chevron returns; likely mascot bounce / hearts float animation

### Onboarding - Gender Selection [pro_screen_028.webp] (free)
- **Purpose:** Collect gender for calorie/macro/BMR personalization.
- **UI:** Back chevron; Early-stage green progress bar (~small fill); Raccoon mascot avatar + chat bubble 'Select your gender.'; Option 'Female' (selected: green border + light-green fill, red-hair face emoji); Option 'Male' (blond face emoji, unselected white); Option 'Non-binary' (sparkles icon, unselected white); Dark pill 'Next >' button
- **iOS:** ProgressView; Circle avatar + speech bubble card; VStack of single-select RoundedRectangle cards; Image/emoji icons; Capsule primary Button
- **Data:** Gender enum {female, male, nonBinary}
- **Interactions:** Tap to single-select (green highlight); tap Next to advance; back chevron returns

### Onboarding - Age Picker [pro_screen_029.webp] (free)
- **Purpose:** Collect age via a scrollable wheel for personalization of calorie targets.
- **UI:** Back chevron; Green progress bar (~partial fill); Raccoon mascot avatar + chat bubble 'What's your age?'; Vertical number wheel showing faded 22, 23, bold centered '24', then faded 25, 26; Dark pill 'Next >' button
- **iOS:** Picker (.wheel style) or custom scroll snap wheel; ProgressView; Circle avatar + speech bubble; Capsule primary Button
- **Data:** Age integer (selected center value, e.g. 24)
- **Interactions:** Scroll wheel to snap-select age; center value emphasized; tap Next to advance

### Onboarding - Activity Level [pro_screen_030.webp] (free)
- **Purpose:** Capture activity level (used for TDEE/calorie goal calculation).
- **UI:** Back chevron; Green progress bar (~60% fill); Raccoon mascot avatar + chat bubble 'What's your activity level?'; Card 'Not active' - 'I quickly lose my breath climbing stairs' (red 1-bar signal icon, unselected); Card 'Lightly active' - 'Sometimes I do short workouts to keep myself moving' (orange 2-bar icon, SELECTED green border + green fill); Card 'Moderately active' - 'I maintain a regular exercise routine of 1-2 times per week' (green 3-bar icon, unselected); Card 'Highly active' - 'Fitness is a core part of my lifestyle' (green 4-bar icon, unselected); Dark pill 'Next >' button
- **iOS:** ProgressView; Circle avatar + speech bubble; VStack of single-select cards each with title + subtitle + bar-chart icon; Image (signal-bar style icons); Capsule primary Button
- **Data:** Activity level enum {notActive, lightlyActive, moderatelyActive, highlyActive}
- **Interactions:** Tap a card to single-select (green highlight); tap Next to advance; back chevron returns

### Onboarding - Height Picker [pro_screen_031.webp] (free)
- **Purpose:** Collect height with unit toggle for BMI/calorie personalization.
- **UI:** Back chevron; Green progress bar (~75% fill); Raccoon mascot avatar + chat bubble 'How tall are you?'; Vertical number wheel: faded 149, 150, bold centered '151', faded 152, 153; Unit toggle on right: 'cm' (active, bold black) over 'ft' (faded/inactive); Dark pill 'Next >' button
- **iOS:** Picker (.wheel) for height value; Segmented unit toggle (cm/ft) - Picker or custom VStack toggle; ProgressView; Circle avatar + speech bubble; Capsule primary Button
- **Data:** Height value (151) + unit selection {cm, ft}
- **Interactions:** Scroll wheel to set height; tap cm/ft to switch units (rescales values); tap Next to advance

### Onboarding - Current Weight + BMI Feedback [pro_screen_032.webp] (free)
- **Purpose:** Collect current weight, choose unit, and show a live BMI calculation with a health classification.
- **UI:** Back chevron; Green progress bar (~80% fill); Raccoon mascot avatar + chat bubble 'What's your current weight?'; Vertical number wheel: faded 48, 49, bold centered '50', faded 51, 52; Unit toggle on right: 'kg' (active bold) over 'lb' (faded); BMI result card: 'Your BMI: 21.9' with green 'Healthy' pill badge and subtext 'Great job! You're in a range that supports overall health.'; Underlined link 'Source of recommendations'; Dark pill 'Next >' button
- **iOS:** Picker (.wheel) for weight; Unit toggle (kg/lb); ProgressView; Circle avatar + speech bubble; Result Card (RoundedRectangle) with computed BMI Text + colored Capsule badge; Link (underlined 'Source of recommendations'); Capsule primary Button
- **Data:** Weight value (50) + unit {kg, lb}; computed BMI (21.9) from height+weight; BMI category {underweight, healthy, overweight, obese}; link URL to sources
- **Interactions:** Scroll wheel to set weight; toggle kg/lb; BMI + category badge update live; tap source link; tap Next to advance

### Personal Summary (BMI & Profile) [pro_screen_033.webp] (free)
- **Purpose:** End-of-quiz summary screen that reflects the user's computed profile back to them (BMI, activity level, diet type, metabolism) to build trust before the plan reveal.
- **UI:** Top green progress bar near completion (~90%); Back chevron top-left; White rounded title card 'Your personal summary'; Grinning grey raccoon mascot peeking up with sparkle accents; White card 'Body Mass Index (BMI)'; Horizontal rainbow BMI gradient bar (blue->green->orange->red) with scale 15 / 18.5 / 25 / 30 / 40; Draggable/positioned thumb with black tooltip 'You: 25'; Range labels Underweight / Normal / Overweight / Obese; Green callout box with check icon 'Healthy BMI' and copy 'You're right where you need to be! It's a perfect base to tone your body and build sustainable habits.'; Row: blue shoe icon, label 'Activity level', value 'Lightly active'; Row: plate icon, label 'Diet type', value 'Balanced'; Row: red flame icon, label 'Metabolism', value 'Balanced: needs steady habits to see change'; Black pill 'Next >' button
- **iOS:** NavigationStack; ProgressView (linear, tinted green); ScrollView; VStack; LinearGradient capsule for BMI bar; GeometryReader for thumb positioning; Custom tooltip (Text in rounded black Capsule); Image (SF Symbols / custom asset icons); Label rows (HStack); RoundedRectangle callout card; Button with Capsule background
- **Data:** computedBMI: Double (25), bmiCategory enum, activityLevel: String, dietType: String, metabolismNote: String; derived from earlier quiz answers (height, weight, age, activity).
- **Interactions:** Tap Next advances onboarding; back chevron returns to previous step; BMI thumb position is data-driven (likely non-interactive display).

### Target Weight Picker [pro_screen_034.webp] (free)
- **Purpose:** Collect the user's goal/target weight via a scroll wheel, with live feedback on whether the goal is realistic.
- **UI:** Green progress bar (~85%); Back chevron; Small raccoon avatar bubble next to chat-style question card 'What's your target weight?'; Vertical number picker showing 55, 56, 57 (selected, bold black), 58, 59 with fade gradient on non-selected values; Unit selector on right: 'kg' (active, bold) over 'lb' (inactive grey); White result card: 'Maintain weight' with green 'Realistic' badge and subtext 'Stay consistent and keep making mindful choices to maintain your weight.'; Underlined link 'Source of recommendations'; Black pill 'Next >' button
- **iOS:** ProgressView; Picker with .wheel style (or custom scroll wheel); Segmented-style unit toggle (Picker .segmented or custom HStack buttons); Chat bubble (RoundedRectangle + avatar Image); Badge (Text in green Capsule); Card (RoundedRectangle); Link / Button (underlined Text); Button (Capsule)
- **Data:** targetWeight: Double (57), unit enum {kg, lb}, goalAssessment: {label: 'Maintain weight', verdict: 'Realistic'}; compares targetWeight against currentWeight to classify goal.
- **Interactions:** Scroll wheel to choose weight; tap kg/lb to switch units (recomputes); assessment card updates live; tap 'Source of recommendations' opens citations; Next advances.

### Goal Speed / Pace Slider [pro_screen_035.webp] (free)
- **Purpose:** Let the user choose how aggressively to pursue their goal (weight loss per week), showing projected goal date.
- **UI:** Green progress bar (fully near 100%); Back chevron; Raccoon avatar + chat card 'How fast you want to achieve your goal?'; Label 'Weight loss per week'; Large value '0.8' with smaller grey 'kg' unit; Green horizontal slider with circular thumb pulled to far right; Slider tick labels: Slow / Optimal / Fast (Fast bold = current); White result card with green check 'Reach your goal by 27 October' and subtext 'Requires a more structured calorie deficit and consistent activity.'; Underlined 'Source of recommendations' link; Black pill 'Next >' button
- **iOS:** ProgressView; Slider (custom tinted green, large thumb); Text with attributed sizing for value+unit; HStack of tick labels; Chat bubble; Result card (RoundedRectangle); Link; Button (Capsule)
- **Data:** weeklyLossRate: Double (0.8 kg/week), pace enum {slow, optimal, fast}, projectedGoalDate: Date (27 October); date recomputed from rate + weight delta.
- **Interactions:** Drag slider to set pace; value, pace label, and projected date update live; Next advances; back returns.

### Realistic Target Interstitial [pro_screen_036.webp] (free)
- **Purpose:** Motivational confirmation screen affirming the goal is achievable, transitioning into plan generation.
- **UI:** Warm cream/yellow background with radiating sunburst rays; Back chevron; Large headline 'Losing 7 kg is a realistic target' with '7 kg' highlighted green; Subtitle 'You are just one step away from getting you personalized plan'; Large happy raccoon mascot (sparkly eyes, blushing, white heart belly, striped tail) with confetti/sparkle accents; Black pill CTA 'Get my personal plan'
- **iOS:** ZStack with radial sunburst (custom Shape / Image background); Text with AttributedString for colored '7 kg'; Image (mascot asset); Particle/sparkle overlay (custom); Button (Capsule, full-width)
- **Data:** weightToLose: Double (7 kg) computed as currentWeight - targetWeight; isRealistic flag.
- **Interactions:** Tap 'Get my personal plan' triggers the plan-generation loading sequence; back returns to pace screen.

### Personalizing Plan Loader (15%) [pro_screen_037.webp] (free)
- **Purpose:** Plan-generation progress screen (step 1 of 4 active) building anticipation while showing social proof via a rotating App Store review.
- **UI:** Light green background; Large circular progress ring at '15%' with small green arc; Heading 'Personalizing plan'; Checklist with circular indicators: 'Analyzing your answers' (in-progress spinner), 'Defining nutrient requirements', 'Estimating weight progress', 'Adjusting nutrition tips' (pending); White testimonial card: bold title 'I absolutely love this app', 5 gold stars, long review body about the cute character and improved relationship with food; Page dots (4) with first active
- **iOS:** Circular progress (Circle with trim + overlay Text); ProgressView circular for active step / Image checkmarks; VStack checklist rows; Testimonial card (RoundedRectangle); Star rating (HStack of SF Symbol star.fill); TabView .page or custom PageControl (dots)
- **Data:** progress: Double (0.15), steps: [{title, state: pending/active/done}], testimonials: [{title, stars:5, body}] cycled on a timer.
- **Interactions:** Auto-advancing timer drives the ring percentage and step completion; testimonial card auto-rotates (page dots reflect index); no user action required.

### Personalizing Plan Loader (80%) [pro_screen_038.webp] (free)
- **Purpose:** Continuation of the plan-generation loader, step 3 in progress, with a second rotating testimonial.
- **UI:** Circular progress ring at '80%' (large green arc); Heading 'Personalizing plan'; Checklist: 'Analyzing your answers' (green check done), 'Defining nutrient requirements' (green check done), 'Estimating weight progress' (in-progress spinner), 'Adjusting nutrition tips' (pending); White testimonial card: 'BitePal helped me a lot...', 5 gold stars, body about learning calorie intake and best meals without giving up ice cream, '10/10!'; Page dots with second active
- **iOS:** Circle trim progress + Text; Checklist rows with checkmark.circle.fill (green) and circular spinner; Testimonial card; Star HStack; PageControl dots
- **Data:** progress: 0.80; steps states updated (2 done, 1 active); current testimonial index 2.
- **Interactions:** Timer-driven progress; testimonial carousel auto-advance; passive screen.

### Personalizing Plan Loader (97%) [pro_screen_039.webp] (free)
- **Purpose:** Near-complete plan-generation loader, step 4 in progress, with a third rotating testimonial.
- **UI:** Circular progress ring at '97%' (almost full green arc); Heading 'Personalizing plan'; Checklist: first three steps green-checked, 'Adjusting nutrition tips' (in-progress spinner); White testimonial card: 'It's soooooo helpful...', 5 gold stars, body about improved relationship with food and calorie deficit, praising the responsive team; Page dots with third active
- **iOS:** Circle trim progress + Text; Checklist rows; Testimonial card; Star HStack; PageControl dots
- **Data:** progress: 0.97; steps states (3 done, 1 active); testimonial index 3.
- **Interactions:** Timer-driven; auto-rotating testimonials; passive.

### Personalizing Plan Loader (99% complete) [pro_screen_040.webp] (free)
- **Purpose:** Final state of the plan-generation loader (all steps done) with the last rotating testimonial, just before the plan reveal.
- **UI:** Circular progress ring at '99%' (full green ring); Heading 'Personalizing plan'; Checklist: all four steps green-checked (Adjusting nutrition tips now near-done); White testimonial card: 'I love love LOVE this app', 5 gold stars, body praising friendly atmosphere, encouraging texts from the raccoon buddy, and non-discriminatory eating suggestions; Page dots with fourth active
- **iOS:** Circle trim progress + Text; Checklist rows; Testimonial card; Star HStack; PageControl dots
- **Data:** progress: 0.99; all steps done; testimonial index 4 (last).
- **Interactions:** On reaching 100% auto-navigates to the plan-ready reveal screen; passive.

### Plan Ready + App Store Rating Prompt (stars) [pro_screen_041.webp] (free)
- **Purpose:** Plan-reveal screen (goal, projected chart, nutrition recommendations) with a native iOS App Store rating prompt overlaid to capture a review at peak excitement.
- **UI:** Background (blurred/dimmed): confetti, subtitle 'Your personal plan is ready', headline 'Reach 50 kg by 27 October' with '50 kg' green; Partially visible 'Proj...(Projection)' card showing '57 k(g)' and a line chart; Green check bullets: 'See the first visible results in just 3 weeks', 'Reach your goal by 27 October', 'Habits will help you sustain your success'; 'Nutrition recommendations' section with calorie figure ~'1,2..' (red flame) and a Carbs/Fats/Proteins macro bar; Black pill CTA 'Commit to my goal >'; FOREGROUND: native SKStoreReviewController-style alert with raccoon app icon, 'Enjoying BitePal?', 'Tap a star to rate it on the App Store.', 5 blue tappable stars, 'Cancel' and 'Submit' buttons
- **iOS:** Underlying plan view (ScrollView, Charts framework line chart, macro bar with Capsules, bullet rows); Native rating dialog (SKStoreReviewController.requestReview, or a custom replica using .alert / overlay); Button (Capsule CTA)
- **Data:** targetWeight: 50 kg, currentWeight: 57 kg, goalDate: 27 October, projectionSeries: [Date: Weight] for chart, dailyCalories: ~1,2xx, macros: {carbs, fats, proteins} percentages; rating: Int (1-5) for review prompt.
- **Interactions:** Tap a star then Submit to leave an App Store rating (or Cancel to dismiss); underneath, 'Commit to my goal' proceeds (likely to paywall/sign-up); chart is the projected weight curve.

### Plan Ready + Rating Thank-You / Write a Review [pro_screen_042.webp] (free)
- **Purpose:** Follow-up state of the native rating prompt after the user taps 5 stars, encouraging them to write a full App Store review; same plan-reveal screen behind.
- **UI:** Same blurred plan background: confetti, 'Your personal plan is ready', 'Reach 50 kg by 27 October', projection card '57 k', green check bullets (results in 3 weeks / reach goal by 27 October / habits sustain success), 'Nutrition recommendations' with '1,2..' calories and macro bar (Carbs/Fats/Proteins); FOREGROUND: native review dialog with raccoon icon, 'Thanks for your feedback.', 'You can also write a review.', 5 filled gold stars, blue link 'Write a Review', blue 'OK' button
- **iOS:** Same underlying plan view (Charts, macro bar); Native App Store review confirmation dialog (system SKStoreReviewController flow, or custom replica); Button / Link styling
- **Data:** submittedRating: 5; same plan data (targetWeight 50 kg, goalDate 27 October, calories ~1,2xx, macros). 'Write a Review' deep-links to App Store write-review URL.
- **Interactions:** Tap 'Write a Review' opens App Store review composer; tap 'OK' dismisses and returns to the plan screen where 'Commit to my goal' continues the flow.

### Personalized Plan Ready - Projected Progress (top) [pro_screen_043.webp] (free)
- **Purpose:** Celebratory reveal of the user's computed personal plan at the end of onboarding, leading them toward committing to a goal. Shows projected weight-loss trajectory and begins nutrition recommendations.
- **UI:** Confetti decoration (red, yellow, blue, green specks) on light mint background; Eyebrow label 'Your personal plan is ready' with sparkle icon; Large headline 'Reach 50 kg by 27 October' with '50 kg' highlighted in green; White rounded card titled 'Projected progress'; Line/area weight curve from '57 kg' start node (Today) descending to '50 kg' target node (27 October), then a flat green 'Maintain goal' segment; X-axis labels 'Today' and '27 October'; pill value tags '57 kg' and '50 kg'; Green checkmark bullet list: 'See the first visible results in just 3 weeks', 'Reach your goal by 27 October', 'Habits will help you sustain your success'; Start of second card 'Nutrition recommendations' with calorie figure '1,2..' and a segmented macro bar (yellow/blue/green) with Carbs/Proteins legend; Sticky dark pill button 'Commit to my goal >'
- **iOS:** ScrollView; VStack; Swift Charts (LineMark/AreaMark/PointMark with annotations); RoundedRectangle cards; Image (SF Symbol checkmark.circle.fill); Capsule button (sticky overlay); ZStack for confetti particles / Lottie or Canvas animation
- **Data:** startWeight (57 kg), goalWeight (50 kg), goalDate (27 Oct), projected weight curve points, maintain phase, dailyCalories (~1,283 kcal), macro split
- **Interactions:** Scrolls vertically to reveal nutrition/fasting/hydration cards; tapping 'Commit to my goal' advances onboarding (toward paywall); chart may animate the curve drawing on appear

### Personalized Plan - Nutrition, Fasting & Hydration cards [pro_screen_044.webp] (free)
- **Purpose:** Mid-scroll of the personal plan summary showing calculated daily nutrition targets, an intermittent fasting schedule, and a daily hydration target.
- **UI:** Card 'Nutrition recommendations' with flame icon and '1,283 kcal'; Segmented macro progress bar (yellow=Carbs, blue=Fats, green=Proteins); Macro legend with dots and values: Carbs 128 g, Fats 43 g, Proteins 96 g; Caption 'Based on your needs, we calculated your daily calories and macro balance. You can always adjust them in the app.'; Card 'Fasting schedule' with blue moon icon '8.5 h Fasting time' and green cutlery icon '15.5 h Eating time'; Two-segment bar (blue fasting / green eating) representing the 16:8-style window; Caption 'Your fasting schedule is based on your eating window. You can change your goal anytime in settings.'; Card 'Daily hydration' with blue droplet icon and '2,0..' (liters/ml) value plus caption about water goal; Sticky dark pill button 'Commit to my goal >'
- **iOS:** ScrollView; VStack of RoundedRectangle cards; Custom segmented bar (HStack of Capsules / GeometryReader); HStack macro legend with Circle swatches; Image (SF Symbols: flame.fill, moon.fill, fork.knife, drop.fill); Capsule sticky CTA button
- **Data:** dailyCalories 1283 kcal; macros carbs 128 g / fats 43 g / proteins 96 g; fastingHours 8.5; eatingHours 15.5; dailyWaterGoal (~2,0 L)
- **Interactions:** Continuous vertical scroll between plan cards; sticky CTA persists; tapping CTA proceeds to next onboarding step

### Personalized Plan - Social Proof & Mascot (bottom) [pro_screen_045.webp] (free)
- **Purpose:** Bottom of the plan-summary scroll adding credibility (5-star social proof) and an emotional mascot moment before the commit action.
- **UI:** Tail of a prior card: bold 'Adapted to lightly active lifestyle' with caption 'Follow your daily nutrition recommendations and achieve your goals stress free with foods you love.'; Speech-bubble shaped white card with small pink heart, headline 'Over 10,000+', subtext 'With 5-star reviews worldwide', and a row of 5 gold/orange stars; Large grey raccoon mascot illustration (content/proud pose) below the bubble; Underlined link 'Source of recommendations'; Dark pill button 'Commit to my goal >'
- **iOS:** ScrollView; RoundedRectangle speech bubble with custom pointer tail (Path/Shape); HStack of star Images (SF Symbol star.fill); Image (mascot asset); Button (link style); Capsule CTA button
- **Data:** reviewCount (10,000+), starRating (5), recommendation source URL, activity level label
- **Interactions:** End of scroll; tapping 'Commit to my goal' transitions to the BitePal Plus paywall; 'Source of recommendations' opens a citation/web link

### Onboarding - Take Care of Bubba (Health Meter Explainer) [pro_screen_096.webp] (free)
- **Purpose:** Educational/coaching modal that explains the gamification mechanic: logging meals fills the pet's health meter (hearts).
- **UI:** Large bold headline 'Now you should take care of Bubba'; Subtitle 'Every time you log a meal, you fill Bubba health meter'; Row of 4 filled red heart icons (the health meter); Large happy grey raccoon mascot (eyes closed, content/smiling) sitting; Black pill primary button 'Got it!' at the bottom; Status bar; home indicator
- **iOS:** VStack centered layout; Text (large title + secondary subtitle); HStack of heart.fill Images; Image/Lottie mascot illustration; Capsule primary Button ('Got it!')
- **Data:** Static onboarding/explainer copy, mascot asset, health meter heart count
- **Interactions:** Tap 'Got it!' to dismiss the explainer and continue onboarding/to home

### Onboarding / Recalculate Plan - Main Goal (chat-style question) [pro_screen_131.webp] (free)
- **Purpose:** Goal-selection step in a chat-style onboarding (or Recalculate plan) flow asking the user's main weight goal, presented by the raccoon mascot.
- **UI:** Top progress bar (thin, green segment near start indicating early step) with back chevron (<); Small round raccoon mascot avatar next to a white chat bubble; Chat-bubble question 'What's your main goal?'; Three selectable option cards: 'Lose weight' (green-outlined/selected, descending bar+arrow icon), 'Maintain weight' (yellow scale icon), 'Gain weight' (red kettlebell icon); Black pill 'Next >' button at bottom
- **iOS:** NavigationStack with back button; ProgressView (linear) for onboarding progress; HStack mascot avatar + chat bubble (RoundedRectangle); Selectable RoundedRectangle option rows with SF Symbol/emoji icons and selected-state border; Button (black Capsule) 'Next'
- **Data:** Onboarding progress (step index); selected main goal (Lose / Maintain / Gain weight) used to drive calorie & macro plan calculation
- **Interactions:** Tap an option to select (green border highlight); tap 'Next' to advance to next onboarding question; back chevron returns to previous step; progress bar advances per step

### Select Gender [pro_screen_134.webp] (free)
- **Purpose:** Conversational onboarding/edit step for selecting the user's gender, framed as a chat message from the raccoon mascot.
- **UI:** Back chevron (top-left); Circular raccoon mascot avatar (grey, blue background); White chat-bubble prompt 'Select your gender.'; Option pill 'Male' (white, unselected); Option pill 'Female' (selected, green tint fill + green border); Option pill 'Non-binary' (white, unselected); Dark pill primary button at bottom with checkmark: 'Done'
- **iOS:** NavigationStack with back button; HStack: Image (mascot) + chat bubble built from RoundedRectangle/Text; VStack of large selectable Buttons styled as cards; Selection state via @State with green accent overlay/stroke; Capsule-shaped bottom Button (Label with checkmark SF Symbol)
- **Data:** Selected gender enum {male, female, nonBinary}; current selection = female.
- **Interactions:** Tap a pill to single-select (highlights green). Tap 'Done' to commit and advance/pop. Back chevron returns.

### Age Picker [pro_screen_135.webp] (free)
- **Purpose:** Conversational step to set the user's age via a vertical scrolling number wheel.
- **UI:** Back chevron (top-left); Raccoon mascot avatar; Chat bubble 'How old are you?'; Vertical number picker: dimmed 24, 25; bold centered selected '26'; dimmed 27, 28; Dark capsule 'Done' button with checkmark
- **iOS:** NavigationStack; Mascot + chat bubble HStack; UIPickerView-style wheel via SwiftUI Picker with .wheel style (or custom scroll snap); Selected value emphasized with larger bold font, neighbors faded; Capsule Button 'Done'
- **Data:** age: Int (range of years), selected = 26.
- **Interactions:** Scroll wheel to change age, snapping to nearest value with the center bold. 'Done' commits. Back returns.

### Height Picker [pro_screen_136.webp] (free)
- **Purpose:** Conversational step to set height with a number wheel plus a cm/ft unit toggle.
- **UI:** Back chevron; Raccoon mascot avatar; Chat bubble 'How tall are you?'; Number wheel: dimmed 149, 150; bold selected '151'; dimmed 152, 153; Unit selector at right: 'cm' (bold/active) over 'ft' (dimmed); Dark capsule 'Done' button with checkmark
- **iOS:** NavigationStack; Mascot + chat bubble; SwiftUI Picker (.wheel) for the value column; Second small wheel or segmented/stacked toggle for unit (cm/ft); Capsule Button 'Done'
- **Data:** height value Int = 151, unit enum {cm, ft} = cm.
- **Interactions:** Scroll value wheel; tap/scroll unit to switch cm vs ft (recomputes displayed value). 'Done' commits; back returns.

### Eating Window Hours [pro_screen_138.webp] (free)
- **Purpose:** Conversational step to set the daily eating window using paired Start/Finish time wheels.
- **UI:** Back chevron; Raccoon mascot avatar; Chat bubble 'Between what hours do you eat?'; Two column labels 'Start' and 'Finish'; Start wheel: dimmed 4:30am, 5:00am; bold selected '5:30 am'; dimmed 6:00am, 6:30am; Finish wheel: dimmed 8:00pm, 8:30pm; bold selected '9:00 pm'; dimmed 9:30pm, 10:00pm; Dark capsule 'Done' button with checkmark
- **iOS:** NavigationStack; Mascot + chat bubble; Two side-by-side SwiftUI Pickers (.wheel) inside an HStack, each with a column caption; Capsule Button 'Done'
- **Data:** eatingWindow: start time = 5:30 am, finish time = 9:00 pm (30-min increments).
- **Interactions:** Scroll each wheel independently to set start/finish; values snap and bold at center. 'Done' commits; back returns.

### Excluded Products Picker [pro_screen_139.webp] (free)
- **Purpose:** Conversational multi-select grid for choosing foods/allergens the user does not eat.
- **UI:** Back chevron; Raccoon mascot avatar; Chat bubble 'Choose products you don't eat.'; Wrapping grid of selectable chips: 'All meat', 'Animal products', 'Citrus fruits', 'Dairy' (selected, red dot + red border), 'Eggs', 'Fish', 'Gluten' (selected, red dot + red border), 'Nuts', 'Red meat', 'Seafood', 'Seeds', 'Shellfish', 'Soy'; '+' chip to add a custom product; Dark capsule 'Done' button with checkmark
- **iOS:** NavigationStack; Mascot + chat bubble; Flow/wrap layout (iOS 16 Layout protocol or LazyVGrid) of Toggle-like chip Buttons; Selected chips use red stroke + leading status dot; '+' Button opens custom add (alert/sheet with TextField); Capsule Button 'Done'
- **Data:** availableProducts: [String]; selectedExclusions set currently = {Dairy, Gluten}. Supports user-added custom entries.
- **Interactions:** Tap chips to multi-select/deselect (toggles red highlight). Tap '+' to add custom item. 'Done' commits selection; back returns.

## Onboarding / Home/Dashboard (1)

### Home Dashboard - 'Log your first meal' Coachmark [pro_screen_057.webp] (free)
- **Purpose:** First-run coachmark overlay dimming the dashboard and spotlighting the '+' add button to teach the user to log their first meal.
- **UI:** Dimmed/darkened Today dashboard behind overlay; Handwritten caption 'Log your first meal...'; Curved hand-drawn arrow pointing to the add button; Spotlight ring highlighting the circular black '+' button; Faintly visible underlying 'Calories eaten', '0 kcal', macro labels, tab bar, fasting card 'Tue, 9:00 PM'
- **iOS:** ZStack overlay with black opacity / .ultraThinMaterial dimmer; Spotlight mask (Canvas / shape cutout); Text (custom handwritten font); Image (arrow asset); TapGesture
- **Data:** Onboarding/coachmark completion flag (hasLoggedFirstMeal / tutorial step).
- **Interactions:** Tap the highlighted '+' to proceed to logging; tap elsewhere to dismiss the coachmark.

## Home/Dashboard (11)

### Home / Today Dashboard [pro_screen_056.webp] (free)
- **Purpose:** Main daily dashboard showing the mascot, fasting status, calories eaten, macros, water, and quick-add. Central hub of the app.
- **UI:** Header 'Today' with dropdown chevron and date prev/next arrows (< >); Illustrated green forest/garden scene with apple trees and bushes; Large grey raccoon mascot named 'Bubba'; Four red heart icons (health/streak hearts); Flame emoji with '0' (streak counter); Calendar/gift glyph; Fasting card: 'Next 12h fasting' with pencil edit icon, 'Tue, 9:00 PM', green 'Start fasting' button; White card 'Calories eaten' with info icon, big '0 kcal'; Black circular '+' add button; Macro rows: 'Carbs', 'Fats', 'Proteins' each with progress bar and gram value; Bottom floating tab bar: Home (house), Stats (bar chart), Settings (gear); Partially visible 'Water' card at bottom
- **iOS:** ScrollView; ZStack (illustrated background); Image (animated mascot); HStack of heart Images; RoundedRectangle card containers; ProgressView (macro bars); Button (Start fasting capsule, circular + FAB); custom floating TabView; Menu (Today date picker)
- **Data:** Selected date, mascot name, hearts/health state, streak count, fasting schedule (window, start time, duration), calories eaten vs goal, macro grams consumed vs target, water intake.
- **Interactions:** Tap '+' to open camera/log meal; tap 'Start fasting' to begin a fast; tap pencil to edit fasting plan; tap date arrows to change day; tap tab bar to switch Home/Stats/Settings; scroll for water and more cards.

### Streak Celebration [pro_screen_084.webp] (free)
- **Purpose:** Gamified celebration screen rewarding the user for logging, showing current daily streak and weekly progress dots, with option to share.
- **UI:** Large red flame illustration containing the grey raccoon mascot wearing black/red sunglasses; Big number '1' overlapping the flame; Bold headline 'day streak!'; Subtitle 'Building healthy eating habits with BitePal App'; Weekday row: Tue (highlighted with green pill + green check), Wed, Thu, Fri, Sat, Sun, Mon each with grey empty circle; Dark pill 'Share' button with download/share icon; Text-only 'Continue' button at bottom
- **iOS:** VStack centered layout; Image / ZStack for flame + mascot + numeral composition; Text with large bold font for streak count; HStack of weekday cells (VStack: weekday Text + Circle/Checkmark); Capsule Button for Share (UIActivityViewController / ShareLink); Plain Button for Continue
- **Data:** Current streak count (1), streak start, per-weekday completion booleans (Tue=true), current weekday highlight, app name
- **Interactions:** Tap 'Share' opens iOS share sheet (see screen 085); tap 'Continue' dismisses to home; confetti/scale entrance animation likely

### iOS Share Sheet (Streak Image) [pro_screen_085.webp] (free)
- **Purpose:** Native iOS share sheet presented over the streak screen to share the generated streak image.
- **UI:** Blurred background showing the red flame + raccoon streak graphic; System share sheet card: thumbnail of shared image with label 'PNG - 213 KB', close (X) button top-right; App icon row: AirDrop, Messages, Mail, Notes, (partial Reminders); Action list rows with icons: 'Copy', 'Save Image', 'Assign to Contact', 'Print', 'Add to New Quick Note', partial 'Create Watch...'
- **iOS:** UIActivityViewController / SwiftUI ShareLink presenting the system share sheet (not custom UI); The underlying app uses ImageRenderer to produce the shareable PNG
- **Data:** Rendered streak image (PNG, ~213 KB) passed to share sheet; system-provided activity/extension list
- **Interactions:** Tap an app icon or action to share/save/copy the image; tap X to dismiss share sheet; swipe app row horizontally

### Home Dashboard (Today) [pro_screen_087.webp] (free)
- **Purpose:** Main home screen showing the pet mascot, daily calorie/macro summary, fasting status, and quick logging; central navigation hub.
- **UI:** Header 'Today' with dropdown chevron, date navigation arrows (< >); Illustrated forest/garden scene background with large grey raccoon mascot named 'Bubba'; Pet name 'Bubba' with 4 red heart icons (health/happiness); Streak indicator 'ðŸ”¥ 1' and a gift/treats box icon; Green fasting banner: 'Next 12h fasting' with pencil, 'Tue, 9:00 PM', and 'Start fasting' button; White summary card: 'Calories eaten (i)' label, big '427 kcal', circular progress ring with purple arc and '+' add button; Macro rows: Carbs (32/128 g, yellow bar), Fats (29/?? g, blue bar), Proteins (9/?? g, green bar); Recent meal thumbnail (salad photo); Floating bottom tab bar: Home (house), Stats (bar chart), Settings (gear); Partial 'Water' card peeking at bottom
- **iOS:** ScrollView with parallax header; Image for animated mascot scene (could be Lottie/Rive); HStack for hearts + streak + treats; Custom fasting banner card with Capsule button; Card with ZStack circular ProgressView (trim ring) + Button '+'; ProgressView/Capsule macro bars in HStack; Custom floating tab bar (Capsule background, SF Symbols house/chart.bar/gearshape)
- **Data:** Selected date; pet name & health hearts; streak count; fasting schedule (next window, start time, type 12h); calories eaten (427) vs goal; macro consumed/goal for carbs/fats/protein; recent meals list with photos; water intake
- **Interactions:** Tap '+' or central add to log food/open camera; tap date arrows to change day; tap 'Start fasting'; edit fasting via pencil; tap tab bar to switch Home/Stats/Settings; scroll to water and more cards; tap meal thumbnail for detail

### Home / Today Dashboard [pro_screen_095.webp] (free)
- **Purpose:** Main daily home screen showing the pet mascot in its environment, daily calorie intake, macro progress, fasting status, streak, and quick access to log food.
- **UI:** 'Today' header with dropdown chevron and date navigation arrows (< >); Full-bleed illustrated forest/garden background with trees and apples; Large grey raccoon mascot 'Bubba' standing center; Pet name label 'Bubba'; Row of 4 red heart icons (health/care meter, all filled); Streak indicator: fire emoji + '1'; Calendar/gift icon (top-right of stats row); Fasting card: 'Next 12h fasting' with pencil edit, 'Tue, 9:00 PM', and a 'Start fasting' button; White 'Calories eaten' card with info (i) icon, big '617 kcal', and a circular '+' add button with a purple progress ring; Macro progress section: Carbs 38/(goal) g, Fats 45/(goal) g, Proteins 16/(goal) g each with colored progress bars (yellow/blue/green); Thumbnail row of logged meal photos (salad, peanut butter jar); Floating bottom tab bar: Home (house), Stats (bar chart), Settings (gear); Partially visible 'Water' card at bottom
- **iOS:** ScrollView with custom illustrated header; NavigationStack with date picker menu; Animated mascot (Lottie); HStack of heart Image symbols; Custom fasting card (RoundedRectangle + Button); Card with circular ProgressView ring + '+' Button (plus.circle); Custom macro ProgressView bars; LazyHGrid/ScrollView for meal thumbnails; Custom floating TabBar (HStack of SF Symbols: house.fill, chart.bar.fill, gearshape.fill)
- **Data:** Selected date, pet name & health/heart meter, streak count, fasting schedule (next window, start time, duration), calories eaten (617) vs goal, macro intake vs goals (carbs 38, fats 45, proteins 16), logged meal photos, water intake
- **Interactions:** Tap date arrows/dropdown to change day; tap 'Start fasting' to begin a fast; tap '+' or open camera to log food; tap meal thumbnails to view details; switch tabs; scroll to water tracking

### Home - Active Fasting (night, sleeping mascot) [pro_screen_107.webp] (free)
- **Purpose:** Home dashboard while a fast is in progress, showing the live fasting timer, streak, calories and macros, and recent meals.
- **UI:** 'Today' header with dropdown + day nav chevrons; Night sky scene with sleeping raccoon mascot 'Bubba' and house; Fasting ring/clock icon + live timer '11:56:49'; Streak fire emoji '1' and a calendar/badge icon; Fasting status row 'Fasting goal 14h âœï¸' and 'Tue, 1:02 PM' end time; Red 'End fasting' pill button; White card 'Calories eaten' = '617 kcal' with circular '+' add button (purple progress ring); Macro bars Carbs 38g (orange), Fats 45g (blue), Proteins 16g (green) with goal denominators; Logged meal thumbnails (salad, jar); Floating bottom tab bar: Home, Stats (bar chart), Settings (gear); 'Water' card peeking below
- **iOS:** ZStack themed background (time-of-day gradient + illustration); TimelineView/Timer for live countdown; Capsule 'End fasting' Button (red); Card with Gauge/ProgressView ring + add Button; Custom ProgressView macro bars; Custom floating TabBar; HStack of meal thumbnails
- **Data:** activeFast {goalHours 14, startTime, endTime 'Tue 1:02 PM', elapsed 11:56:49}; streak count 1; calories eaten 617; macros carbs 38/x, fats 45/x, proteins 16/x; recent meals[]
- **Interactions:** Tap 'End fasting' to end; tap pencil to edit goal; tap '+' to log food; switch days; tab bar navigation; scroll to Water/Fasting cards

### Home - Fast Canceled (daytime, happy mascot) [pro_screen_110.webp] (free)
- **Purpose:** Home after canceling the fast: shows success toast, no active fast, and a prompt to start the next fast.
- **UI:** 'Today' header (partly behind toast) + day nav chevrons; Green toast 'Current fast was canceled' with check icon; Daytime sky scene with cheerful sitting raccoon 'Bubba' + house; Four red heart icons (lives/health indicator); Streak fire '1' + calendar/badge icon; Card 'Next 14h fasting âœï¸' / 'Tue, 7:00 PM' with a (disabled-looking) 'Start fasting' pill button; White 'Calories eaten' card 617 kcal with '+' ring button; Macro bars Carbs 38, Fats 45, Proteins 16; Logged meal thumbnails + a blue circular item; Floating tab bar Home/Stats/Settings; 'Water' card peeking
- **iOS:** Success toast overlay (Capsule + checkmark); Themed ZStack background; HStack of heart Images; Card with scheduled-next-fast info + Capsule 'Start fasting' Button; Calories card with ring + macro ProgressViews; Custom floating TabBar
- **Data:** toast 'Current fast was canceled'; nextFast {goal 14h, scheduled 'Tue 7:00 PM'}; hearts/lives=4; streak=1; calories 617; macros 38/45/16
- **Interactions:** Toast auto-dismisses; tap 'Start fasting' to begin next fast; pencil to edit next-fast schedule; '+' to log food; tab navigation; day switching

### Home - Calories, Water & Fasting Cards (scrolled) [pro_screen_111.webp] (free)
- **Purpose:** Scrolled Home view showing the calorie summary, an empty water tracker, and the start of a 'No fast' fasting card.
- **UI:** 'Today' header + dropdown + day nav chevrons over blue/yellow sky; Calories card: 'Calories eaten' 617 kcal, '+' ring button (purple), macro bars Carbs 38g (orange), Fats 45g (blue), Proteins 16g (green) with goal denominators, two logged meal thumbnails (salad, jar); Water card: 'Water' 0 ml, circular '+' button, grid of ~10 empty glass icons (first has a '+'), 'Daily goal: 2,500 ml', overflow '...' menu; Fasting card starting: 'Fasting' / 'No fast...' with circular fasting icon; Floating tab bar Home/Stats/Settings; Home indicator
- **iOS:** ScrollView of dashboard cards; Calories card with ring ProgressView + macro bars; Water card: LazyVGrid of glass Images (tappable), circular add Button, Menu (...); Text goal label; Custom floating TabBar
- **Data:** calories 617; macros carbs 38, fats 45, proteins 16 with goals; water current 0 ml / goal 2,500 ml / glass count; fasting state 'No fast'
- **Interactions:** Tap a glass or '+' to add water; tap '...' for water options; tap calorie '+' to log food; scroll to reveal Fasting card; tab navigation

### Today Dashboard - Meal Deleted Toast [pro_screen_116.webp] (free)
- **Purpose:** Home/Today dashboard after a meal was deleted; shows updated calorie total, macros, recent meal thumbnails, water tracker (empty), and fasting card, with a success toast.
- **UI:** Status bar; 'Today' header with date dropdown caret and left/right day-navigation arrows; Green success toast 'Meal has been deleted' with check icon (cloud decoration behind); 'Calories eaten' card with overflow icon; '617 kcal'; Circular add (+) button with purple progress ring; Macro mini-bars: Carbs 38/128 g (yellow), Fats 45/42 g (blue), Proteins 16/106 g (green); Two recent-meal thumbnail images (salad, supplement tub); 'Water' card: '0 ml', circular + add button; Grid of 10 empty glass icons (first shows + to add); 'Daily goal: 2,500 ml'; Overflow '...' on water card; 'Fasting' card: 'No Fastingâ€¦' with circular clock/timer icon and intro copy; Floating pill tab bar: Home (house, active), Stats (bar chart), Settings (gear)
- **iOS:** ScrollView dashboard; Custom toast overlay (Capsule + Label, auto-dismiss); Card RoundedRectangles; Circular progress add button (ZStack Circle + Trim ring + plus); ProgressView-style macro bars; LazyVGrid of glass cells (Image/Shape); Custom floating TabBar (Capsule HStack of SF Symbols house/chart.bar/gearshape); DatePicker-style header with chevrons
- **Data:** Day summary: caloriesEaten 617 + goal ring; macros consumed vs target {carbs 38/128, fats 45/42, proteins 16/106}; meals[] thumbnails; water current 0 / goal 2500 ml; fasting state none; selected date.
- **Interactions:** Tap +/ring to log food; tap water + or a glass to add water (see 117-120); swipe arrows to change day; toast auto-dismisses; tab bar switches sections; tap fasting to start a fast.

### Home - Today (Fasting + Nutrition Score + Fiber cards, scrolled) [pro_screen_123.webp] (free)
- **Purpose:** Scrolled-down view of the daily Home dashboard showing additional summary cards below the calorie hero: fasting status, daily nutrition quality score, and fiber intake quality.
- **UI:** Top header 'Today' with dropdown chevron and left/right day-navigation arrows (< >); Blurred grey cloud illustrations at top over blue-to-yellow gradient sky background; White rounded 'Fasting' card: label 'Fasting', large heading 'No fasting yet', body 'You didn't have any finished fast this day. Start your new fast today to track your progress.', footer 'Fasting goal: 14h', circular clock/timer icon (ring) top-right; White rounded 'Nutrition score' card: label 'Nutrition score', large rating 'Average', circular progress ring showing value '53' (yellow arc), grey hexagonal food/egg/apple illustration, caption 'More nutritious food = more shiny awards'; Partial 'Fiber' card at bottom: label 'Fiber', large rating 'Low', circular ring with value '2' and a red notification dot, body text about missing fruits/veggies/whole grains; Floating bottom tab bar pill with Home (filled), Stats (bar chart), Settings (gear) icons
- **iOS:** ScrollView; VStack; Custom card views (RoundedRectangle + shadow); LinearGradient background; Circle + trim for progress rings (Canvas/Shape); ZStack for ring + centered Text; Custom floating TabView/tab bar; Image for mascot/food illustrations; Button for day navigation chevrons
- **Data:** Selected date; fasting session state (none/active), fasting goal hours (14h); nutrition score value (53/100) and qualitative label (Average); fiber score value (2) and qualitative label (Low); progress ring percentages
- **Interactions:** Vertical scroll through stacked summary cards; tap date header to change day; left/right arrows to navigate days; tapping clock icon likely starts fasting; tapping cards drills into Fasting / Nutrition score / Fiber detail; bottom tab bar switches between Home/Stats/Settings

### Home - Yesterday (mascot, streak, fasting CTA, calories hero) [pro_screen_124.webp] (free)
- **Purpose:** Top of the Home dashboard for a past day ('Yesterday') showing the raccoon mascot, mood hearts, streak, the next-fast schedule with a Start fasting CTA, and the calories-eaten hero card with macro bars.
- **UI:** Header 'Yesterday' with dropdown chevron and < > day-navigation arrows; Yellow scene background with blurred clouds and a small house illustration; Large grey raccoon mascot 'Bubba' (cute mascot with mask); Mascot name label 'Bubba'; Row of four red heart icons (mood/health hearts); Streak indicator: flame emoji with count '1'; Calendar/awards icon top-right of mascot row; Fasting scheduling banner (muted yellow pill): 'Next 14h fasting' with pencil edit icon, 'Tue, 7:00 PM', and rounded 'Start fasting' button; White 'Calories eaten' card: label 'Calories eaten' with info (i) icon, large value '0 kcal', circular black '+' add button; Macro section: 'Carbs', 'Fats', 'Proteins' columns with thin progress bars and gram values (0g each, with goal grams faint); Faint 'Add your first meal' hint with curved arrow pointing to + button; Floating bottom tab bar (Home filled, Stats, Settings); Partial 'Water' card peeking at bottom
- **iOS:** ScrollView; ZStack with Image scene background; Image (mascot); HStack of heart Images; Label with SF Symbol flame; Capsule banner with Button ('Start fasting'); Card RoundedRectangle; Circle Button with plus SF Symbol; ProgressView/Capsule bars for macros; Custom floating TabView
- **Data:** Selected date (Yesterday); mascot identity/name (Bubba) and mood state (4 hearts); streak count (1); scheduled next fast (14h, Tue 7:00 PM); calories eaten (0 kcal) vs goal; macro intake vs goals for carbs/fats/proteins (grams)
- **Interactions:** Scroll; change day via header/arrows; tap pencil to edit fasting schedule; tap 'Start fasting' to begin a fast; tap '+' to add a meal/food; tap info icon for calorie explanation; tap mascot/hearts for mascot detail; bottom tab navigation

## Camera/AI Scan (16)

### Camera Tips - Get Better Results (Camera Permission) [pro_screen_058.webp] (free)
- **Purpose:** First page of a camera onboarding carousel teaching good photo technique, presented over the system camera permission prompt.
- **UI:** Top bar: 'X' close (left), info 'i' (right); Two tilted food photo cards: left with green thumbs-up badge, right with red thumbs-down badge; Native alert '"BitePal" Would Like to Access the Camera' body 'BitePal uses the camera to capture photo of your meal'; Alert buttons 'Don't Allow' / 'Allow'; Heading 'Get better results'; Body 'Position your food inside the circle and capture a clear photo showing as many ingredients as possible'; Page dots (2 dots, first active); Black pill 'Next' button
- **iOS:** Sheet / fullScreenCover; TabView (.page style) carousel; Image cards with badge overlays (ZStack + Circle); AVCaptureDevice.requestAccess triggering system permission UIAlertController; PageControl dots; Capsule Button
- **Data:** Camera permission status; carousel page index; onboarding tip content.
- **Interactions:** Tap 'Allow'/'Don't Allow' on the permission alert; tap 'Next' to advance carousel; swipe between tip pages; tap 'X' to close; tap 'i' for info.

### Camera Tips - Get Better Results (Page 1) [pro_screen_059.webp] (free)
- **Purpose:** Camera onboarding carousel page 1 (after permission granted) demonstrating a good vs bad food photo for accurate AI recognition.
- **UI:** Top bar: 'X' close (left), info 'i' (right); Blurred salad background; Two tilted photo cards: left (overhead chicken/tomato salad) with green thumbs-up = good; right (cropped close-up salad) with red thumbs-down = bad; Heading 'Get better results'; Body 'Position your food inside the circle and capture a clear photo showing as many ingredients as possible'; Page dots (first active); Black pill 'Next' button
- **iOS:** TabView (.page); ZStack with blurred background Image; RoundedRectangle photo cards with rotationEffect; Badge Circles (SF Symbols hand.thumbsup/down); PageControl; Capsule Button
- **Data:** Carousel page index; static tip imagery/copy.
- **Interactions:** Tap 'Next' to go to page 2 (Scan the label); swipe carousel; tap 'X' to close.

### Camera Tips - Scan the Label (Page 2) [pro_screen_060.webp] (free)
- **Purpose:** Second carousel page teaching how to photograph a nutrition label for accurate scanning; final tip before entering the camera.
- **UI:** Top bar: 'X' close, flash/lightning icon (center), info 'i'; Two tilted nutrition-label photo cards: left with green thumbs-up (clear, full label, '70' calories visible), right with red thumbs-down (cropped/angled label); Heading 'Scan the label'; Body 'Take a clear photo showing all the details - name, serving size, calories, and macros.'; Page dots (second/last active); Black pill 'Got it' button
- **iOS:** TabView (.page); RoundedRectangle photo cards with rotation; Badge Circles; PageControl; Capsule Button (final CTA)
- **Data:** Carousel page index; static label-photo tips.
- **Interactions:** Tap 'Got it' to dismiss tips and open the camera; swipe back to page 1; tap 'X' to close.

### Camera Capture - Meal/Label Scanner [pro_screen_061.webp] (free)
- **Purpose:** Live camera viewfinder for snapping a photo of a meal (or nutrition label) for AI calorie/macro analysis.
- **UI:** Live camera preview of a salad (tomatoes, lettuce, chickpeas, red cabbage, sweet potato); Top bar: 'X' close, flash/lightning toggle, info 'i'; Segmented toggle pill: 'Meal' (selected, white) / 'Label'; Bottom black control bar; 'Gallery' button with thumbnail icon (left); Large white circular shutter button (center); 'Type' button with keyboard icon (right, manual entry)
- **iOS:** AVCaptureVideoPreviewLayer / UIViewRepresentable camera view; ZStack overlay controls; Picker (segmented Meal/Label); Button (shutter Circle, Gallery PHPicker, Type manual entry, flash toggle); SF Symbols (xmark, bolt, photo, keyboard, info.circle)
- **Data:** Camera feed, capture mode (Meal vs Label), flash state, captured photo buffer; gallery image selection.
- **Interactions:** Tap shutter to capture and trigger AI scan; toggle Meal/Label mode; tap 'Gallery' to pick from library; tap 'Type' for manual entry; toggle flash; tap 'X' to exit.

### Scanning Plate (AI Analysis Loading) [pro_screen_062.webp] (free)
- **Purpose:** Loading/processing state shown after capture while the AI analyzes the photo to identify food and estimate calories/macros.
- **UI:** Light grey background; 'X' close button (top left); Large circular cropped image of the captured salad with an animated horizontal scan line sweeping across; Heading 'Scanning plate.'; Subtext 'Powered by AI' with sparkle; Grey raccoon mascot peeking up from the bottom edge with pink cheeks
- **iOS:** ZStack; Circle-clipped Image (clipShape(Circle())); Animated scan line (Rectangle + linear repeating .animation); Text; Image (mascot); ProgressView (indeterminate / custom); async Task awaiting AI result
- **Data:** Captured image being uploaded/analyzed; AI inference job status; resulting detected food items, calories, macros (pending).
- **Interactions:** Auto-advances to the food detail/results screen when analysis completes; tap 'X' to cancel the scan and return.

### Edit Meal - AI Detected Ingredients Info Sheet [pro_screen_063.webp] (pro)
- **Purpose:** Educational bottom-sheet shown over the AI food-scan review screen, explaining that the AI ingredient detection may be imperfect and that the user should review/edit detected items before logging.
- **UI:** Dimmed background showing the review screen: 'Today, 10:54 AM' date label with chevron, 'Meal' dropdown pill (top right); Large title 'Tomato, lettuce, chickpea, cabbage salad'; 'Serving(s)' row with value '1'; Section header 'AI-detected ingredients' with info (i) icon; Ingredient rows with pencil edit icons: 'Cherry tomatoes 150 g', 'Lettuce 100 g', 'Chickpeas 80 g'; White rounded bottom sheet titled 'AI-detected ingredients'; Blue sparkle icon + text 'Sometimes AI scanner might miss or mislabel items. For best results, please review and edit the ingredients.'; Red gear/settings icon + text 'You can choose your preferred measurement units in Settings.'; Black full-width pill button 'Got it!'
- **iOS:** sheet presentationDetents; VStack; HStack; Label with SF Symbols (sparkles, gearshape); Text; Button (Capsule background); Color overlay / .background dimming; RoundedRectangle
- **Data:** Meal name, timestamp, serving count, list of AI-detected ingredients (name + weight in grams), user measurement-unit preference
- **Interactions:** Tap 'Got it!' dismisses the sheet; swipe-down to dismiss; underlying info (i) icon triggers this sheet

### Edit Meal - AI Ingredient Review [pro_screen_064.webp] (pro)
- **Purpose:** Main meal review/edit screen after an AI photo scan, letting the user adjust servings, edit each detected ingredient and its weight, add ingredients, and confirm the meal for logging.
- **UI:** Top sheet grabber handle; 'Today, 10:54 AM' date/time with chevron; 'Meal' dropdown pill (top right); Title 'Tomato, lettuce, chickpea, cabbage salad'; 'Serving(s)' label with editable boxed value '1'; Section header 'AI-detected ingredients' + info (i) icon; Editable ingredient rows each with pencil icon and boxed gram value: 'Cherry tomatoes 150 g', 'Lettuce 100 g', 'Chickpeas 80 g', 'Dressing 50 g', 'Red cabbage 20 g'; '+ Add new ingredient' row; Black pill button 'Confirm >' with chevron
- **iOS:** NavigationStack / sheet; ScrollView; Form or List rows; TextField (for grams, served count); Button; Label with pencil SF Symbol; Capsule confirm button; Menu/Picker for 'Meal' type
- **Data:** Meal name, timestamp, meal type (breakfast/lunch/etc.), serving count, editable ingredient list each with name + weight (grams)
- **Interactions:** Tap pencil/name to rename ingredient; tap gram box to edit weight; tap serving box to change servings; tap '+ Add new ingredient'; tap 'Meal' dropdown to choose meal type; tap date to open date/time picker; 'Confirm' submits for AI calorie analysis

### Select Meal Date & Time Picker [pro_screen_065.webp] (pro)
- **Purpose:** Bottom-sheet wheel picker for assigning the date and time a meal was eaten, presented over the meal review screen.
- **UI:** Dimmed underlying meal review screen (same salad meal, ingredients visible); White rounded bottom sheet titled 'Select meal date & time'; Three/four-column scrolling wheel picker: day column ('Sun, Aug 24', 'Yesterday', 'Today' highlighted, ...), hour column ('8','9','10' selected,'11','12'), minute column ('52','53','54' selected,'55','56'), AM/PM column ('AM' selected, 'PM'); Selected row in bold: 'Today 10 54 AM'; Black full-width pill button 'Done'
- **iOS:** sheet presentationDetents; DatePicker (.wheel style) or custom Picker columns; Picker / UIDatePicker wrapper; Button (Capsule); Text
- **Data:** Selectable date (relative labels Today/Yesterday/explicit dates), hour, minute, AM/PM -> resolves to a Date for the meal log entry
- **Interactions:** Scroll wheels to choose day/hour/minute/AM-PM; tap 'Done' to confirm and update the date label on the review screen; swipe down to dismiss

### Edit Meal - AI Detected Ingredients Info Sheet (7:52 AM variant) [pro_screen_066.webp] (pro)
- **Purpose:** Same educational 'AI-detected ingredients' info bottom sheet as 063, shown over the review screen with a different meal timestamp (Today, 7:52 AM), reminding users to review and edit AI results.
- **UI:** Dimmed review screen: 'Today, 7:52 AM' label, 'Meal' dropdown; Title 'Tomato, lettuce, chickpea, cabbage salad'; 'Serving(s) 1'; 'AI-detected ingredients' header + info icon; Rows: 'Cherry tomatoes 150 g', 'Lettuce 100 g', 'Chickpeas 80 g'; White info bottom sheet 'AI-detected ingredients'; Blue sparkle icon + 'Sometimes AI scanner might miss or mislabel items. For best results, please review and edit the ingredients.'; Red gear icon + 'You can choose your preferred measurement units in Settings.'; Black pill button 'Got it!'
- **iOS:** sheet presentationDetents; VStack; Label with SF Symbols (sparkles, gearshape); Text; Button (Capsule)
- **Data:** Meal name, timestamp (7:52 AM), servings, AI ingredient list, units preference
- **Interactions:** Tap 'Got it!' to dismiss; swipe to dismiss

### Edit Ingredient Name - Keyboard Active (Lettuce) [pro_screen_067.webp] (pro)
- **Purpose:** Inline editing state of the ingredient review list where the user is renaming an ingredient ('Lettuce') with the iOS keyboard raised; shows a red delete/remove indicator for the active row.
- **UI:** 'Serving(s) 1' (partly scrolled); 'AI-detected ingredients' header + info icon; 'Cherry tomatoes 150 g'; Active editable row 'Lettuce|' with red circular minus/delete icon and text caret, value '100 g'; 'Chickpeas 80 g', 'Dressing 50 g', 'Red cabbage 20 g'; '+ Add new ingredient' (faded); Black 'Confirm >' pill button (floating above keyboard); Full iOS QWERTY keyboard with '123', 'space', 'next' keys and emoji key
- **iOS:** TextField with .focused state; List / ForEach editable rows; onDelete / red minus SwiftUI.Image (minus.circle.fill); Keyboard (system); Button (Capsule); @FocusState
- **Data:** Editable ingredient name string for the focused row, its gram weight, plus full ingredient list
- **Interactions:** Type to rename ingredient; tap red minus to delete the row; 'next' key moves to next field; tap 'Confirm' to save; keyboard editing

### Add New Ingredient - Keyboard Active (caesar salad sauce) [pro_screen_068.webp] (pro)
- **Purpose:** Ingredient review list while the user types a newly added ingredient ('caesar salad sauce') with keyboard up; demonstrates the add-ingredient flow.
- **UI:** 'Serving(s)' (partly visible at top); 'AI-detected ingredients' header + info icon; 'Cherry tomatoes 150 g', 'Chickpeas 80 g', 'Dressing 50 g', 'Red cabbage 20 g'; New active row 'caesar salad sauce|' with red minus delete icon and caret, value '10 g'; '+ Add new ingredient' row; Black 'Confirm >' pill button; Full iOS QWERTY keyboard (123 / space / next / emoji)
- **iOS:** TextField with @FocusState; List / ForEach with onDelete; Image minus.circle.fill (red); Keyboard; Button (Capsule)
- **Data:** New ingredient name + default/typed gram value (10 g); full ingredient list
- **Interactions:** Type new ingredient name; edit its gram value; delete via red minus; 'next' to advance; 'Confirm' to finalize and run analysis

### AI Analysis Loading - Hmm Something Tasty [pro_screen_069.webp] (pro)
- **Purpose:** Full-screen loading/processing state after confirming the meal, while the AI analyzes the photo and calculates calories; features the raccoon mascot and an animated progress ring around the food photo.
- **UI:** Close 'X' button top-left; Large circular food photo (tomatoes, lettuce, chickpeas, dressing) framed by a green circular progress ring (animated); Loading text 'Hmm, something tasty..'; Grey raccoon mascot illustration (smiling, peeking from bottom) with a thought/speech curve line; Status bar with green recording dot
- **iOS:** ZStack; Circle with .trim stroke (progress ring) + rotation animation; AsyncImage / Image clipped to Circle; Text; Image (mascot asset, Lottie or PNG); Button (xmark dismiss)
- **Data:** In-flight analysis state; the captured meal image; progress percentage
- **Interactions:** Indeterminate/animated ring while waiting; tap 'X' to cancel/dismiss; auto-advances to result screen when analysis completes

### Camera Capture - Meal Mode [pro_screen_088.webp] (free)
- **Purpose:** Live camera scanner for logging food; 'Meal' capture mode active to photograph a dish for AI recognition.
- **UI:** Dark camera viewfinder with live preview of a Skippy peanut butter jar (blue lid); Top bar: close (X) left, flash/lightning icon center, info (i) right; White circular focus/subject highlight overlay; Mode toggle pill: 'Meal' (selected, white) and 'Label' (unselected) with small icons; Bottom controls: 'Gallery' icon left, large white shutter button center, 'Type' icon right
- **iOS:** AVCaptureSession camera preview (UIViewRepresentable); Top toolbar HStack with SF Symbols xmark / bolt / info.circle; Segmented Capsule toggle (Meal/Label) custom; Bottom HStack: PhotosPicker (Gallery), large Circle shutter Button, Type/keyboard button; Overlay Circle subject indicator
- **Data:** Camera feed; capture mode (Meal vs Label); flash state; selected gallery image input
- **Interactions:** Tap shutter to capture; toggle Meal/Label; tap Gallery to pick a photo; tap Type for manual entry; tap flash; tap X to close; tap (i) for help

### Camera Capture - Label Mode [pro_screen_089.webp] (free)
- **Purpose:** Same camera scanner with 'Label' mode active to scan a nutrition-facts label for OCR-based logging.
- **UI:** Camera viewfinder showing the same Skippy peanut butter jar, framed slightly differently; Top bar: X (close), flash icon, info (i); Circular focus reticle positioned over the label area; Mode toggle pill: 'Meal' (unselected) and 'Label' (selected/white) with icons; Bottom controls: 'Gallery', large white shutter button, 'Type'
- **iOS:** AVCaptureSession preview (UIViewRepresentable); Same top toolbar SF Symbols; Custom segmented Capsule toggle (Label selected state); Bottom HStack with PhotosPicker, shutter Circle Button, Type Button; Circle focus reticle overlay (VisionKit for label OCR)
- **Data:** Camera feed; capture mode = Label; flash state; target = nutrition label region for OCR
- **Interactions:** Toggle to Label; tap shutter to scan label; switch back to Meal; Gallery/Type alternatives; X to close

### AI Label Scanning / Processing [pro_screen_090.webp] (free)
- **Purpose:** Loading/processing state after capturing a label while AI analyzes it; provides feedback that scanning is in progress.
- **UI:** Light grey background; Large rounded card with the captured photo of the peanut butter jar; Animated horizontal scan-line sweeping across the image (light band); Bold text 'Scanning label...'; Subtext 'Powered by AI âœ¨'; Raccoon mascot peeking up from the bottom edge (grey, blushing cheeks)
- **iOS:** VStack centered; RoundedRectangle image container with animated scan-line (LinearGradient overlay animated with TimelineView/withAnimation); ProgressView (indeterminate) implied; Text labels; Image of mascot anchored to bottom; Lottie/Rive optional for scan animation
- **Data:** Captured image being processed; scan mode (label); AI processing status
- **Interactions:** Automatic transition to results when AI finishes; likely no user input except wait; X to cancel (off-screen at top)

### AI Scan - Analyzing Captured Food Photo [pro_screen_093.webp] (free)
- **Purpose:** Transitional/loading state shown immediately after the user captures a food photo (here, a Skippy peanut butter jar's nutrition label). The app is analyzing the image while reassuring the user with mascot feedback.
- **UI:** Top-left close 'X' button to dismiss the capture flow; Large rounded-corner photo card with a thick neon-green border outlining the detected/in-focus subject (a peanut butter jar showing its blue lid and 'Nutrition Facts' label); Centered status caption text 'Hmm, something tasty.'; Grey raccoon mascot (Bubba) at the bottom with eyes squinted/sniffing and pink cheek blush, in a thinking/savoring pose; Status bar (cellular, wifi, battery)
- **iOS:** NavigationStack with toolbar close button (Image(systemName: "xmark")); ZStack; RoundedRectangle with green stroke overlay over an AsyncImage/Image; Text for caption; Lottie/animated Image for mascot; ProgressView (implicit analyzing state)
- **Data:** Captured photo (UIImage), AI analysis in-progress state, randomized encouragement copy string, mascot animation state
- **Interactions:** Tap X to cancel scan; screen auto-advances to the food detail/results screen once AI analysis completes; mascot animates while loading

## Food Detail (18)

### Meal Detail - Calories & Macros Result [pro_screen_070.webp] (pro)
- **Purpose:** Final analyzed meal detail screen showing total calories, macro breakdown, ingredient list, mascot congratulatory reaction, and a Done confirmation; the AI scan result page.
- **UI:** Back chevron (<), title 'Tomato, lettuce, chickpea, cabba...', subtitle 'Today, 7:52 AM', edit/compose icon (top right); Circular food photo at top; Mascot speech bubble: 'Veggies and beans? My tummy is doing a happy dance! This is awesome.' with happy raccoon mascot and confetti; Round share/export button (up-arrow) over the photo; 'Calories & macros' card with info icon and 'Edit' button; Flame icon + large '427 kcal'; Horizontal stacked macro bar (orange/blue/green); Legend with values: 'Carbs 32 g' (orange dot), 'Fats 29 g' (blue dot), 'Proteins 9 g' (green dot); 'Ingredients' card with info icon; Green ingredient chips with checkmarks: 'Cherry tomatoes', 'Chickpeas', 'Red cabbage', 'Caesar salad sauce'; orange chip 'Dressing'; Black floating pill button with checkmark 'Done'
- **iOS:** ScrollView; NavigationStack with toolbar (back, edit); Image clipped Circle; Speech-bubble overlay (RoundedRectangle + Text); Card (RoundedRectangle, .shadow); Custom segmented macro bar (HStack of Capsules / GeometryReader); HStack legend with Circle dots; FlowLayout / WrappingHStack of ingredient Capsule chips with checkmark SF Symbols; Button (ShareLink for export); Capsule 'Done' button
- **Data:** Meal: name, timestamp, image, total kcal (427), macros (carbs 32g, fats 29g, proteins 9g) with proportions, ingredient list with confirmed/edited state, mascot reaction message
- **Interactions:** Tap 'Edit' to revise macros; tap 'Done' to save meal to log; tap share/export button to open iOS share sheet; tap info icons for explanations; back to return; edit icon to rename

### Calorie Estimate Info Sheet [pro_screen_071.webp] (pro)
- **Purpose:** Educational bottom-sheet explaining how calories are estimated/calculated and recommended daily intake, opened from the (i) info icon on the calories & macros card.
- **UI:** Dimmed meal-detail header behind ('Tomato, lettuce, chickpea, cabba...', back chevron, edit icon); White sheet with grabber handle; Decorative illustration: green apple with red flame and a cute face; Title 'Calorie Estimate'; Body copy: 'Calories measure the energy in food, which you need for everyday activities'; 'We calculate calories by adding up the energy from the macronutrients in your food: carbs and proteins provide 4 calories per gram, while fats provide 9 calories per gram.'; Subheader 'Recommended intake:'; 'Calorie needs vary but generally range from 1,800 to 2,400 calories per day for women and 2,200 to 3,000 for men, based on activity levels and other factors.'; 'Quality is as important as quantity. Choose nutrient-rich foods over empty calories to enhance health benefits.'; Faded disclaimer footer about informational purposes / 'sources we use' / 'send us Email' links
- **iOS:** sheet presentationDetents; ScrollView; Image (illustration asset); Text (titles + body); Link (for sources / email); VStack
- **Data:** Static educational content; macro-to-calorie conversion facts; recommended intake ranges
- **Interactions:** Scroll to read; tap 'sources we use' / 'send us Email' links; swipe down or scroll to dismiss

### Meal Detail - iOS Share Sheet [pro_screen_072.webp] (pro)
- **Purpose:** Native iOS share sheet invoked from the meal detail share button to export/save the meal result image (PNG, 2.2 MB).
- **UI:** Dimmed meal detail behind (food photo, speech bubble 'Veggies and beans? My tummy is doing a happy dance! This is awesome.', mascot, share button); Standard iOS share sheet with file preview thumbnail 'PNG - 2.2 MB' and close 'X'; App row: AirDrop, Messages, Mail, Notes, Reminders (partially visible); Action list: 'Copy' (copy icon), 'Save Image' (download icon), 'Assign to Contact' (person icon), 'Print' (printer icon), 'Add to New Quick Note' (note icon), 'Create Watch...' (partially visible)
- **iOS:** ShareLink / UIActivityViewController (system share sheet); Image render to PNG (ImageRenderer); System-provided activity rows
- **Data:** Rendered meal result image (PNG, ~2.2 MB) generated from the detail card
- **Interactions:** Tap an app/AirDrop to share; tap 'Save Image' to save to Photos; 'Copy'; 'Print'; tap 'X' or swipe down to dismiss

### Food Detail - Photo Library Permission Prompt [pro_screen_073.webp] (free)
- **Purpose:** On the meal/food detail screen, when the user taps the share/upload (or add-photo) control, iOS presents the native photo library permission dialog so BitePal can access camera-roll images of the meal.
- **UI:** Navigation bar (green) with back chevron, title 'Tomato, lettuce, chickpea, cabba...', subtitle 'Today, 7:52 AM', and edit/pencil icon; Circular meal hero image (salad) behind the dialog; Raccoon mascot illustration (left), upload/share icon button (right) in rounded grey circle; Blurred food detail content behind: 'Calories' card with flame icon and large number '4...', yellow progress bar, 'Edit' link, macro row 'Carbs 32 g', 'Proteins'; Ingredient chips: 'Cherry tomatoes', 'Chickpeas', 'Red cabbage', 'Caesar salad sauce' (green checks), 'Dressing' (amber); Native iOS system alert: title '"BitePal" Would Like to Access Your Photo Library', body 'BitePal uses the camera roll to get images of your meal', 4x2 photo thumbnail grid, '455 Photos, 43 Videos', metadata note about location/depth/captions/audio, blue actions 'Limit Access...', 'Allow Full Access', 'Don't Allow'; Dark pill 'Done' button with checkmark at bottom
- **iOS:** NavigationStack / custom toolbar; PHPickerViewController or PHPhotoLibrary.requestAuthorization (native system alert, not custom); ZStack with blurred background (.blur / Material); ScrollView with rounded cards; Image (clipShape Circle); HStack of capsule chips (Label + checkmark); Button (Done) styled as Capsule
- **Data:** Meal record (title, timestamp, hero photo, calories, macros: carbs/protein/fat, ingredient list with status). Photo library authorization status; PHAsset thumbnails count (455 photos, 43 videos).
- **Interactions:** Tap share/add-photo triggers system permission sheet; user chooses Limit Access / Allow Full Access / Don't Allow; back chevron returns; pencil edits meal; Done dismisses.

### Food Detail - Ingredients, Nutrition Score & Awards [pro_screen_074.webp] (free)
- **Purpose:** Lower portion of the meal detail screen showing detected ingredients, an overall nutrition score, earned nutrition 'awards', and dietary highlights for the logged salad.
- **UI:** Green nav bar: back chevron, title 'Tomato, lettuce, chickpea, cabba...', subtitle 'Today, 7:52 AM', pencil edit icon; 'Ingredients' card with info (i) icon; chips: 'Cherry tomatoes', 'Chickpeas', 'Red cabbage', 'Caesar salad sauce' (green check), 'Dressing' (amber); 'Nutrition score' card with info icon, green check badge + bold 'Good', segmented progress/slider bar with green fill and marker, value '80'; 'Awards' section with info icon; three hexagonal badges: 'Complex carbs' (wheat icon), 'Rich in fiber' (apple icon), 'Vitamins and minerals' (A/C/D color circles); 'Highlights' section: amber chip 'High in sodium'; Partially visible 'Protein' section: 'Low in protein'; Dark floating 'Done' pill button with checkmark
- **iOS:** ScrollView with card containers (RoundedRectangle / GroupBox); FlowLayout / WrapHStack of Capsule chips; Custom segmented score bar (Canvas or HStack of capsules) with marker; LazyHGrid / HStack of hexagon badge views (custom Shape or Image); Label rows for highlights; Capsule Button (Done)
- **Data:** Ingredient list with health status; nutrition score (0-100, label 'Good', value 80); award flags (complex carbs, rich in fiber, vitamins/minerals); highlights (high in sodium, low in protein).
- **Interactions:** Tap info icons for explanations; tap an award hexagon opens the award detail flow (screens 076-082); scroll to reveal protein section; Done dismisses.

### Ingredient Info Sheet - Cherry Tomatoes [pro_screen_075.webp] (free)
- **Purpose:** Bottom-sheet detail for a single tapped ingredient, giving its nutrient profile and a fun fact, educating the user about cherry tomatoes.
- **UI:** Sheet grabber handle at top; Large bold title 'Cherry tomatoes'; 'Nutrient Profile' section label; Green check bullet 'Vitamin C:' followed by 'Cherry tomatoes are a good source of vitamin C, an antioxidant.'; Green check bullet 'Lycopene:' followed by 'They contain lycopene, an antioxidant associated with various health benefits.'; Divider; 'Did You Know' section: 'Cherry tomatoes are a versatile ingredient, great in salads, snacks, or cooked dishes.' and 'They are available in various colors, each offering a slightly different flavor profile.'; Dark pill 'Get it!' button at bottom
- **iOS:** Sheet (.presentationDetents) presented modally; VStack with Text styles (largeTitle, section headers .secondary); Label rows with green checkmark SF Symbol; Divider; Capsule Button ('Get it!')
- **Data:** Ingredient detail: name, list of nutrient highlights (nutrient name + description), 'Did You Know' paragraphs.
- **Interactions:** Sheet swipe-to-dismiss via grabber; 'Get it!' dismisses sheet and returns to food detail.

### Award Detail Intro - Rich in Fiber [pro_screen_076.webp] (free)
- **Purpose:** Opening card of the 'Rich in fiber' award detail flow, celebrating that the meal is high in fiber with a hero badge and encouraging message.
- **UI:** Sheet grabber handle; Large hexagonal award badge with red apple illustration (green stem) on pink background; Bold title 'Rich in fiber'; Subtitle 'Awesome! Your meal is rich in fiber, keeping your digestion happy and energy steady.'; Dark pill 'Read more >' button with chevron
- **iOS:** Sheet / full-screen cover; VStack centered; Large badge Image (hexagon shape + apple); Text (title bold, body secondary); Capsule Button with HStack(Text + chevron.right)
- **Data:** Award metadata: badge icon, title 'Rich in fiber', celebratory description tied to the meal's fiber content.
- **Interactions:** Tap 'Read more >' advances into the multi-page educational carousel (screens 077-082); swipe down to dismiss.

### Rich in Fiber Education - Page 1 (What is fiber) [pro_screen_077.webp] (free)
- **Purpose:** First slide of the 'Rich in Fiber' educational carousel explaining what fiber is.
- **UI:** Sheet grabber handle; Centered header title 'Rich in Fiber'; Segmented page-progress indicator bar at top (first segment filled, ~10 segments); Large headline text 'Fiber is the material from plant cell walls.' (green); Home indicator at bottom
- **iOS:** Sheet with custom header; Segmented progress indicator (HStack of Capsules / custom ProgressView); TabView (.page style) or paged ScrollView for swipe; Large Text headline
- **Data:** Carousel content array (page index, headline text with highlighted spans). Current page = 1 of ~10.
- **Interactions:** Swipe left/right or tap to advance through pages; progress bar updates; swipe down to dismiss.

### Rich in Fiber Education - Page 2 (Fiber & glucose) [pro_screen_078.webp] (free)
- **Purpose:** Second carousel slide explaining that fiber is a carbohydrate that cannot be broken into glucose and passes through undigested.
- **UI:** Sheet grabber handle; Centered title 'Rich in Fiber'; Page-progress bar (second segment filled); Headline 'It belongs to the carbohydrates, but fiber can't be broken down into glucose. That's why it' (dark) + 'passes through the body undigested.' (green highlight); Home indicator
- **iOS:** TabView page; Custom segmented progress indicator; Text with mixed-color AttributedString; Sheet container
- **Data:** Carousel page 2 content (headline with green-highlighted phrase). Progress 2 of ~10.
- **Interactions:** Swipe to next/previous page; progress advances; swipe down to dismiss.

### Rich in Fiber Education - Page 3 (Benefits) [pro_screen_079.webp] (free)
- **Purpose:** Third carousel slide describing the benefits of fiber-rich food (blood sugar, heart health, satiety).
- **UI:** Sheet grabber handle; Centered title 'Rich in Fiber'; Page-progress bar (~third segment filled); Headline 'Fiber-rich food' (dark) + 'steadies blood sugar, protects heart health, and keeps you full for a longer time.' (green highlight); Home indicator
- **iOS:** TabView page; Segmented progress indicator; Text with AttributedString color spans; Sheet
- **Data:** Carousel page 3 content (benefit statement). Progress 3 of ~10.
- **Interactions:** Swipe to navigate pages; progress updates; swipe down to dismiss.

### Rich in Fiber Education - Page 4 (Food sources list) [pro_screen_080.webp] (free)
- **Purpose:** Fourth carousel slide listing common fiber-rich foods where the nutrient is found.
- **UI:** Sheet grabber handle; Centered title 'Rich in Fiber'; Page-progress bar (~four-five segments filled); Headline 'You can find it in:'; Bulleted list: 'Oatmeal', 'Chia seeds', 'Nuts', 'Beans and lentils', 'Apples and berries'; Home indicator
- **iOS:** TabView page; Segmented progress indicator; VStack of Label/HStack bullet rows (Circle bullet + Text); Sheet
- **Data:** Carousel page 4 content: list of food sources (array of strings). Progress 4 of ~10.
- **Interactions:** Swipe to navigate; progress updates; swipe down to dismiss.

### Rich in Fiber Education - Page 5 (Daily intake + source) [pro_screen_081.webp] (free)
- **Purpose:** Fifth carousel slide stating recommended daily fiber intake with a credible citation.
- **UI:** Sheet grabber handle; Centered title 'Rich in Fiber'; Page-progress bar (more segments filled, ~7-8); Headline 'Adults need 25 to 35 grams (green) of fiber per day from food, not supplements.'; Footer citation link 'Learn More - American Heart Association' (link icon + source); Home indicator
- **iOS:** TabView page; Segmented progress indicator; Text with AttributedString highlight; Link (Learn More) with SF Symbol icon; Sheet
- **Data:** Carousel page 5 content: intake recommendation (25-35 g), citation source label + external URL.
- **Interactions:** Swipe to navigate; tap 'Learn More' opens external source (Safari/SFSafariViewController); swipe down to dismiss.

### Rich in Fiber Education - Final Page (Action tips) [pro_screen_082.webp] (free)
- **Purpose:** Final carousel slide with practical tips to meet fiber intake, completing the educational flow.
- **UI:** Sheet grabber handle; Centered title 'Rich in Fiber'; Page-progress bar (fully/nearly fully filled); Headline 'To meet the fiber intake:'; Green-check tip list: 'Add beans or lentils to salads, soups, and stews', 'Swap white bread and pasta for whole-grain versions', 'Sprinkle chia seeds, flaxseeds, or almonds on your yogurt or salad'; Faint 'RACCOON APPROVED' watermark stamp (raccoon mascot seal); Dark pill 'Got it!' button at bottom; Home indicator
- **iOS:** TabView page (last); Segmented progress indicator (complete); VStack of Label rows with green checkmark SF Symbol; Decorative ZStack watermark Image; Capsule Button ('Got it!')
- **Data:** Carousel final page: actionable tips array; brand 'Raccoon Approved' seal asset. Progress = last of ~10.
- **Interactions:** 'Got it!' dismisses the entire award/education sheet and returns to food detail; swipe down also dismisses.

### Meal Nutrition Analysis Detail [pro_screen_083.webp] (free)
- **Purpose:** Shows an AI-generated nutritional quality breakdown of a logged meal, rating each macro/nutrient and offering improvement suggestions.
- **UI:** Light-green navigation header with back chevron, two-line title 'Tomato, lettuce, chickpea, cabba...' and subtitle 'Today, 7:52 AM', edit (pencil) icon top-right; White rounded card: section label 'Protein' with info (i) icon, brown drop emoji + bold heading 'Low in protein', horizontal range/progress bar with red filled segment and red position marker, value '9g' in red, descriptive text 'Suitable for low-protein diet needs or small meals.'; White card: 'Fiber' label with (i) icon, pinch emoji + 'Optimal fiber' heading, range bar with green filled segment and green marker, value '8g' in green, text 'Okay for most main meals, this range supports good digestion and maintain a balanced diet.'; White card: 'Improve meal' label, yellow emoji + bold 'Reduce sodium' heading, tip text 'Use a homemade dressing with olive oil, lemon juice, and herbs instead of store-bought dressing to control sodium intake.'; Partial 'Keep doing' section peeking at bottom; Floating dark pill button with checkmark + 'Done'
- **iOS:** NavigationStack with custom toolbar (ToolbarItem back/edit); ScrollView + LazyVStack of cards; RoundedRectangle card backgrounds with shadow; Custom GeometryReader-based range bar (ZStack of Capsules) with colored marker; Label / Text with SF Symbols info.circle; Floating Button with Capsule background, overlaid via safeAreaInset or ZStack
- **Data:** Per-nutrient analysis objects: nutrient name, value+unit (protein 9g, fiber 8g), qualitative rating (low/optimal), color/status, descriptive copy; meal title, timestamp; list of improvement tips with emoji + text
- **Interactions:** Tap (i) icons for nutrient info; tap pencil to edit meal; scroll vertically through nutrient cards; tap 'Done' to dismiss and return

### Food Detail - Scanned Result (Skippy Peanut Butter) [pro_screen_094.webp] (free)
- **Purpose:** Shows the AI-recognized food item with its calories, macro breakdown, and nutrition score before saving/logging it. Includes celebratory feedback from the mascot.
- **UI:** Back chevron (top-left); Title 'Skippy peanut butter' with subtitle timestamp 'Today, 10:57 AM'; Edit/pencil icon (top-right) to rename or edit the entry; Hero photo of the scanned peanut butter jar; Confetti graphics + grey raccoon mascot (grinning) with a white speech bubble 'You're on the right track, keep up the good work!'; Circular share/export button (up-arrow tray icon) overlapping the photo; 'Calories & macros' card with info (i) icon and 'Edit' pill button; Flame icon + large '190 kcal'; Horizontal segmented macro bar (yellow/blue/green); Macro legend with values: Carbs 6 g, Fats 16 g, Proteins 7 g; 'Nutrition score' card with info (i) icon and a yellow badge reading 'Average' over a horizontal score scale/slider; Black pill 'Done' button (with checkmark) floating near bottom; Partially visible 'Highlights' section header
- **iOS:** ScrollView; NavigationStack toolbar (back + pencil); AsyncImage hero; Speech-bubble custom view with confetti (TimelineView/Canvas or particle overlay); Card views (RoundedRectangle background); Custom segmented macro bar (HStack of Capsules); Label with SF Symbol flame.fill; Custom horizontal score gauge; Capsule 'Done' button; Button 'Edit' / ShareLink
- **Data:** Food name, logged timestamp, photo, calories (190 kcal), macros (carbs 6g, fats 16g, proteins 7g), nutrition score rating ('Average'), highlights/insights, share payload
- **Interactions:** Tap back to return; tap pencil/Edit to modify portion/values; tap share to export; tap 'Done' to confirm and log the food; scroll for Highlights

### Meal Detail - Calories & Macros [pro_screen_113.webp] (free)
- **Purpose:** Show the AI-analyzed result of a logged meal: hero food photo, a playful mascot reaction, total calories, macro breakdown, and detected ingredients with a confidence/edit affordance.
- **UI:** Back chevron (top-left); Title 'Tomato, lettuce, chickpea, cabbagâ€¦' (truncated); Subtitle timestamp 'Today, 7:52 AM'; Overflow '...' button (top-right); Large circular food photo (salad); Grey raccoon mascot with happy/closed eyes and tiny green chat dots; White speech-bubble card: 'Veggies and beans? My tummy is doing a happy dance! This is awesome.'; Round white share/export button (up-arrow-out icon); 'Calories & macros' card with info (i) icon and 'Edit' pill button; Flame icon + '427 kcal'; Segmented horizontal macro bar (yellow/blue/green); Legend rows: 'Carbs 32 g' (yellow), 'Fats 29 g' (blue), 'Proteins 9 g' (green); 'Ingredients' card with info (i) icon; Green ingredient chips with check icons: 'Cherry tomatoes', 'Chickpeas', 'Red cabbage', 'Caesar salad sauce'; Yellow/amber chip 'Dressing' (lower confidence); Home indicator bar
- **iOS:** NavigationStack with custom toolbar; ScrollView + VStack; Circle-clipped AsyncImage for the food photo; Custom mascot Image with overlaid speech-bubble (RoundedRectangle + Text); RoundedRectangle 'card' containers; Custom segmented macro bar (HStack of Capsules / Canvas); HStack legend with colored Circle dots; FlowLayout / WrapLayout of chip views (Capsule + Label with SF Symbols checkmark.circle.fill); Button for Edit / share (ShareLink) / ellipsis menu
- **Data:** Meal: id, title, photoURL, timestamp, totalCalories (427 kcal), macros {carbs 32g, fats 29g, proteins 9g}, mascotMessage string, ingredients [{name, confidence/state: confirmed=green vs uncertain=amber}].
- **Interactions:** Tap back to return to log; tap '...' opens edit/delete menu (see 114); tap 'Edit' to adjust calories/macros; tap share to export; scroll vertically; ingredient chips likely tappable to confirm/correct.

### Meal Detail - Edit/Delete Menu [pro_screen_114.webp] (free)
- **Purpose:** Contextual popover menu triggered by the '...' overflow button on the meal detail screen, offering edit or delete actions.
- **UI:** Dimmed/blurred meal-detail background (same 427 kcal meal); Floating white popover anchored top-right; Menu row 'Edit meal' with pencil/edit-square icon; Divider line; Menu row 'Delete meal' in red with red trash icon; Mascot peeking with skeptical eyes in background
- **iOS:** Menu or custom popover (overlay + RoundedRectangle card with shadow); Button rows (Label with SF Symbols: square.and.pencil, trash) ; Color.red for destructive row; Background blur/dim using .ultraThinMaterial or color overlay with opacity; Tap-outside-to-dismiss gesture
- **Data:** Same meal context; actions: editMeal(mealID), deleteMeal(mealID). No new data displayed.
- **Interactions:** Tap 'Edit meal' -> edit flow; tap 'Delete meal' -> confirmation sheet (see 115); tap outside popover to dismiss.

### Delete Meal Confirmation Sheet [pro_screen_115.webp] (free)
- **Purpose:** Bottom-sheet confirmation before destructively deleting a meal, warning it will be removed from the meal list and score.
- **UI:** Dimmed meal-detail background; Bottom sheet with grabber handle; Title 'Delete meal?'; Body text 'You won't see this meal and its score in the meal list'; Large red filled 'Delete' button; White/outline 'Cancel' button; Home indicator
- **iOS:** confirmationDialog or custom .sheet with .presentationDetents([.height]); VStack with Text title + subtitle; Capsule/RoundedRectangle Buttons (red destructive filled + neutral bordered cancel); Grabber via presentation drag indicator; Dimmed background overlay
- **Data:** mealID to delete; copy strings for title/body. Confirms removal affecting meal list and daily score.
- **Interactions:** Tap 'Delete' -> removes meal, shows success toast & returns to Today (see 116); tap 'Cancel' or swipe down to dismiss.

## Food Log (3)

### Confirm Food Entry (Serving & Nutrients) [pro_screen_091.webp] (free)
- **Purpose:** Bottom-sheet to review and edit the AI-detected food's serving size and nutrient values before saving to the log.
- **UI:** Bottom-sheet card with grabber handle; Row: 'Today, 10:57 AM' (datetime, dropdown) and meal-category pill 'Snack â–¾' top-right; Bold food title 'Skippy peanut butter'; Section prompt 'How much did you have?'; Editable fields: 'Number of servings' = 1; 'Serving size' = 32.0 g; 'Nutrients per:' field = 32.0 g; Nutrient value fields: 'Calories' 190.0 kcal, 'Carbs' 6.0 g, 'Fats' 16.0 g, 'Proteins' 7.0 g, 'Fiber' 2.0 g; Dark pill 'Confirm >' button at bottom
- **iOS:** Sheet / presentationDetents bottom sheet; Form-like VStack of HStack rows (label + TextField/stepper in rounded field); DatePicker / Menu for time, Menu for category 'Snack'; Numeric TextFields with unit suffix labels; Capsule 'Confirm' Button
- **Data:** Food name; entry datetime; category (Snack/Meal/Beverage/Dessert); servings count; serving size (g); nutrients-per basis (g); per-serving calories, carbs, fats, proteins, fiber
- **Interactions:** Edit servings/serving size/nutrients via tap fields; tap 'Snack' to open category picker (screen 092); tap time dropdown; tap 'Confirm' to log; swipe down to dismiss

### Select Entry Category Picker [pro_screen_092.webp] (free)
- **Purpose:** Modal picker to choose which meal category the food entry belongs to, presented over the confirm-entry sheet.
- **UI:** Dimmed background showing the Skippy peanut butter confirm sheet behind; White bottom-sheet modal titled 'Select entry categorie'; Selectable rows each with emoji icon and label: 'Meal' (crossed fork & knife), 'Beverage' (cup), 'Snack' (popcorn, highlighted with green selected outline/background), 'Dessert' (donut)
- **iOS:** confirmationDialog or custom Sheet with presentationDetents; VStack of selectable RoundedRectangle rows (Button) with emoji + Text; Selected row styled with green stroke/fill overlay; Dimmed background via .presentationBackground / overlay
- **Data:** List of category options (Meal, Beverage, Snack, Dessert) each with icon; currently selected = Snack
- **Interactions:** Tap a category to select and dismiss back to confirm sheet; tap outside / swipe down to cancel

### Today Meal Log Sheet [pro_screen_112.webp] (free)
- **Purpose:** Bottom sheet listing today's logged meals with calories and a share/export action.
- **UI:** Dimmed Home (calories + water cards) behind; Bottom sheet with grabber; Section header 'Today' + share/export icon (up-arrow box); Meal row: salad thumbnail, 'Tomato, lettuce, chickpea, cabbage salad', 'Meal Â· 07:52 am', '427 kcal'; Meal row: peanut butter jar thumbnail, 'Skippy peanut butter', 'Meal Â· 10:57 am', '190 kcal'; Divider between rows; Home indicator
- **iOS:** .sheet with .presentationDetents; List/VStack of meal rows; AsyncImage thumbnails (rounded); Button (share/ShareLink) with square.and.arrow.up icon; Text rows for name/type/time/calories
- **Data:** meals today[] {thumbnail, name, type 'Meal', time, calories}; e.g. salad 427 kcal @07:52am, Skippy peanut butter 190 kcal @10:57am; sum 617
- **Interactions:** Tap a meal row to open Food Detail; tap share icon to export/share today's log; swipe down to dismiss; scroll list

## Water (6)

### Today Dashboard - Water Logged 250 ml [pro_screen_117.webp] (free)
- **Purpose:** Same dashboard showing water intake incremented to 250 ml (one glass filled) with a playful mascot toast; calories now 190 kcal.
- **UI:** 'Today' header; Green toast 'You give water. I do sparkle.' with check icon; 'Calories eaten' 190 kcal with purple progress ring + add button; Macros: Carbs 6/128 g, Fats 16/42 g, Proteins 7/106 g; One recent-meal thumbnail (supplement tub); 'Water' card: '250 ml' with circular add (+) button showing small blue progress dot; Glass grid: first glass filled blue, second glass shows + (next), remaining empty; 'Daily goal: 2,500 ml'; Floating tab bar (Home active, Stats, Settings)
- **iOS:** Same dashboard ScrollView; Toast overlay Capsule; Circular trim ProgressView ring for water; LazyVGrid glass cells with fill state (filled vs empty Shape); Card containers
- **Data:** water current 250 / goal 2500 ml (1 of 10 glasses, 250 ml each); calories 190; macros updated; meal thumbnails.
- **Interactions:** Tapping a glass / + increments water by 250 ml and shows a randomized mascot toast; ring animates fill progress.

### Today Dashboard - Water Logged 500 ml [pro_screen_118.webp] (free)
- **Purpose:** Dashboard with water progressed to 500 ml (two glasses filled) and another encouraging mascot toast.
- **UI:** 'Today' header; Green toast 'More water? That's the spirit!' with check icon; 'Calories eaten' 190 kcal + purple ring + add button; Macros: Carbs 6, Fats 16, Proteins 7 (g, vs goals); Recent-meal thumbnail (supplement tub); 'Water' card: '500 ml' with circular + button and larger blue progress arc; Glass grid: first two glasses filled blue, third shows +, rest empty; 'Daily goal: 2,500 ml'; Floating tab bar
- **iOS:** Dashboard ScrollView; Toast Capsule overlay; Circular progress ring (Trim, blue) for water; LazyVGrid of glass Shapes with fill state; Cards
- **Data:** water 500 / 2500 ml (2 of 10 glasses); calories 190; macros; meals.
- **Interactions:** Tap + or next glass to add another 250 ml; ring fill grows; mascot toast cycles motivational copy.

### Water Intake Entry Sheet (Custom Amount) [pro_screen_119.webp] (free)
- **Purpose:** Bottom sheet to manually enter a custom water amount via numeric keypad and log it.
- **UI:** Dimmed dashboard background (190 kcal card, supplement thumbnail); Bottom sheet with grabber; Title 'Water intake'; Large editable value '1000' with 'ml' unit and text cursor; Black pill 'Log water' button; iOS-style numeric keypad (1-9, 0, delete/backspace key)
- **iOS:** .sheet with presentationDetents; TextField with .keyboardType(.numberPad) styled large, or custom numeric input; Unit Text 'ml'; Capsule primary Button 'Log water'; System numeric keyboard (or custom KeyboardView); Dimmed background overlay
- **Data:** waterAmountInput (ml, integer e.g. 1000); on submit adds to water current and recomputes glasses/progress.
- **Interactions:** Type amount on keypad; backspace to edit; tap 'Log water' to commit and dismiss; swipe down/grabber to cancel.

### Today Dashboard - Water 1,500 ml [pro_screen_120.webp] (free)
- **Purpose:** Dashboard with water at 1,500 ml (six glasses filled) after a larger log, with mascot toast.
- **UI:** 'Today' header; Green toast 'Drinky-drink? Yes-yes!' with check icon; 'Calories eaten' 190 kcal + purple ring + add button; Macros: Carbs 6, Fats 16, Proteins 7; Recent-meal thumbnail (supplement tub); 'Water' card: '1,500 ml' with circular + button and ~3/4 blue progress arc; Glass grid: first six glasses filled blue, seventh shows +, last three empty; 'Daily goal: 2,500 ml'; '...' overflow on water card; Floating tab bar
- **iOS:** Dashboard ScrollView; Toast Capsule; Circular Trim progress ring (blue, larger arc); LazyVGrid glasses with fill states; Cards
- **Data:** water 1500 / 2500 ml (6 of 10 glasses); calories 190; macros; meals.
- **Interactions:** Continue tapping +/glass to add water; ring nearly complete; toast randomizes mascot lines.

### Today Dashboard - Water Goal Reached 2,500 ml [pro_screen_121.webp] (free)
- **Purpose:** Dashboard showing the daily water goal fully reached (all 10 glasses filled), with a completed ring, success state, and celebratory mascot toast.
- **UI:** 'Today' header; Green toast 'You're basically a river now' with check icon; 'Calories eaten' 190 kcal + purple ring + add button; Macros: Carbs 6, Fats 16, Proteins 7; Recent-meal thumbnail (supplement tub); 'Water' card: '2,500 ml' with circular + button surrounded by full blue ring; Glass grid: all 10 glasses filled blue; Green success row with check 'Goal reached: 2,500 ml'; '...' overflow; Floating tab bar
- **iOS:** Dashboard ScrollView; Toast Capsule; Completed circular progress ring (full blue Circle stroke); LazyVGrid all-filled glass Shapes; Success Label (checkmark.circle.fill + green Text); Cards
- **Data:** water 2500 / 2500 ml (10/10 glasses, goal met flag true); calories 190; macros; meals.
- **Interactions:** Goal-reached state; tapping + could still add over-goal; success row confirms completion; toast celebratory.

### Daily Water Goal Setting Sheet [pro_screen_122.webp] (free)
- **Purpose:** Bottom sheet to configure the daily water goal using a discrete slider with preset tick values and a live ml/glasses readout.
- **UI:** Dimmed dashboard background; Bottom sheet with grabber; Title 'Daily water goal'; Large value '2,500' with 'ml' unit; Subtitle '10 glasses'; Discrete blue slider with circular thumb at 2.5 L; Tick labels: '1.5 L', '2 L', '2.5 L' (bold/selected), '3 L'; Black pill 'Save' button; Home indicator
- **iOS:** .sheet with presentationDetents; Large Text value + unit; Custom discrete Slider (Slider with step, or custom track with tick marks and draggable Circle thumb); Tick HStack of Text labels; Capsule primary Button 'Save'; Dimmed overlay
- **Data:** dailyWaterGoal (ml) selectable across presets 1500/2000/2500/3000 ml; derived glasses count (goal/250). Persists user setting.
- **Interactions:** Drag slider to snap between presets; value and glasses update live; tap 'Save' to persist and dismiss; swipe down to cancel.

## Fasting (11)

### Onboarding Carousel - Enjoy Fasting (Intermittent Fasting Timer) [free_screen_006.webp] (free)
- **Purpose:** Carousel slide (page 3 of 5) introducing the intermittent fasting timer feature.
- **UI:** Back chevron (top-left); Page indicator dots with 3rd active (â—‹â—‹â—â—‹â—‹); 'Fasting' label; Large timer readout '00:01:20'; Horizontal segmented fasting progress bar: green filled portion with a crescent-moon icon at the start, a flame icon and a flag/milestone icon as later stage markers; Card with sleeping raccoon mascot curled up on green grass with bushes; Bold headline 'Enjoy fasting'; Subtitle 'Build a healthy habit that you'll actually enjoy'; Black capsule 'Next >' button
- **iOS:** TabView(.page); Text (monospaced timer, Timer/TimelineView); Custom progress bar (Capsule track + filled Capsule) with SF Symbol stage icons (moon.fill, flame.fill, flag.fill); RoundedRectangle card + Image (mascot); Text (title/subtitle); Button (filled black Capsule 'Next'); Back chevron Button
- **Data:** Fasting elapsed time (hh:mm:ss), fasting protocol/stages (e.g., 16:8), stage milestones (sleep, fat-burn/flame, goal/flag), progress fraction. Demo values during onboarding.
- **Interactions:** Live-counting timer animation; swipe or tap 'Next' to advance; back chevron to return; progress bar fills over time toward stage icons.

### Intermittent Fasting Awareness (Yes/No) [pro_screen_007.webp] (free)
- **Purpose:** Onboarding question gauging whether the user is familiar with intermittent fasting (gates the fasting education that follows).
- **UI:** Back chevron; Title 'Do you know about intermittent fasting?'; Option card: green thumbs-up emoji 'Yes' (SELECTED - green border + light-green fill); Option card: red thumbs-down emoji 'No' (white, unselected); Dark pill 'Next >' button
- **iOS:** NavigationStack + custom back button; VStack of two large selectable Buttons (single-select); RoundedRectangle cards with conditional selected styling; Leading emoji Image + Text; Capsule CTA Button
- **Data:** Boolean / enum (knows about IF: yes|no) stored in onboarding profile
- **Interactions:** Tap Yes or No (single-select); Back; Next advances

### Fasting Education (Lose Weight 1.2x Faster) [pro_screen_008.webp] (free)
- **Purpose:** Educate/persuade about intermittent fasting benefits with a clock illustration, headline stat, explanation, and an authority citation.
- **UI:** Back chevron; Circular clock illustration split into green (eating window, fork/knife icon) and blue (fasting window, moon icon) halves with clock hands; Headline 'Fasting makes you lose weight' with blue emphasis '1.2x faster'; Body copy: 'Fasting is a planned break from eating â€” usually for 12 hours or more. It's not just a trend â€” it's backed by science.'; Citation card with Harvard crest: 'Harvard Health Publishing says that intermittent fasting may help with weight loss by reducing insulin levels and improving metabolic health.'; Underlined link 'Source of recommendations'; Dark pill 'Let's go' button
- **iOS:** VStack layout; Custom clock graphic: two Circle().trim arcs + overlaid SF Symbols (fork.knife, moon.fill) + Path clock hands; Text with mixed foreground colors (AttributedString or concatenated Text); Citation Capsule/RoundedRectangle with Image (crest) + Text; Link/Button for source; Capsule CTA Button
- **Data:** Static educational content + citation text/URL; the '1.2x' and '12 hours' are fixed marketing copy
- **Interactions:** Read-only; tap 'Source of recommendations' link (opens reference); Back; 'Let's go' advances

### You're Fasting Only for 8.5h (Fasting Recommendation) [pro_screen_019.webp] (free)
- **Purpose:** Feedback/recommendation screen computing the user's current fasting duration and nudging toward a recommended 12h fast (intermittent-fasting onboarding).
- **UI:** Back chevron; Mascot raccoon (surprised expression) on cream background with green bushes and yellow sparkle stars; Large headline 'You're fasting only for 8.5h' (the '8.5h' highlighted in orange); Recommendation card (cream): clock icon + bold '12h' + orange 'Recommended' badge, body 'We recommend for at least 12 hours without food to support weight loss and avoid late-night snacking.'; Underlined text link 'Source of recommendations'; Black pill CTA 'Got it!'; Home indicator
- **iOS:** NavigationStack + chevron back; ZStack background illustration; Text with AttributedString/colored span for the hour figure; Recommendation Card (RoundedRectangle + HStack: Image clock + Text + Badge Capsule); Link / Button (underlined) for source; Capsule Button 'Got it!'
- **Data:** Computed fasting hours (8.5h) derived from eating window; recommended threshold (12h). Read-only display.
- **Interactions:** Tap 'Source of recommendations' opens citation/web link; 'Got it!' acknowledges and continues onboarding (to screen 020).

### Choose Fasting Goal (Beginner 12h selected) [pro_screen_103.webp] (free)
- **Purpose:** Let the user pick an intermittent-fasting plan duration. Beginner 12h is currently selected; tapping the selected card reveals a Settings button to configure it.
- **UI:** Back chevron; Centered title 'Choose fasting goal'; Selected card with green border + green circular checkmark; Difficulty pill tags: 'Beginner' (green), 'Intermediate' (blue), 'Challenging' (red), 'Custom' (grey); Large duration labels '12h', '14h', '16h', 'Custom'; Descriptions e.g. 'You probably already follow this rhythm. It's a great way to start and build the habit.', '14:10 plan â€” fast for 14 hours and eat within 10...', 'The classic 16:8 plan. Fast for 16 hours...', 'Create your own fasting plan to fit your unique rhythm and lifestyle.'; 'Settings' outlined button inside the selected card; Home indicator
- **iOS:** NavigationStack with custom toolbar back button; ScrollView + LazyVStack of selectable cards; RoundedRectangle cards with conditional green stroke; Capsule difficulty badges with tinted backgrounds; Image(systemName: checkmark.circle.fill); Button (outlined Settings)
- **Data:** List of FastingPlan {id, difficulty, hours (12/14/16/custom), title, description, isSelected}; selectedPlanId
- **Interactions:** Tap a card to select it (green border + checkmark animate in); tapping the already-selected card exposes 'Settings'; back chevron to dismiss; vertical scroll

### Choose Fasting Goal (Intermediate 14h selected + toast) [pro_screen_104.webp] (free)
- **Purpose:** Same plan picker, now with the Intermediate 14h card selected and a confirmation toast '14h goal set' shown at top.
- **UI:** Back chevron; Green pill toast '14h goal set' with white check icon overlapping the nav bar; Cards: 12h Beginner (deselected), 14h Intermediate (selected, green border + green checkmark, shows 'Settings' button), 16h Challenging, Custom; Difficulty pills Beginner/Intermediate/Challenging/Custom; Plan descriptions; 'Settings' outlined button inside the 14h card; Home indicator
- **iOS:** Same card list as 103; Transient toast via overlay + .transition(.move/.opacity) auto-dismiss; Capsule toast with Image(systemName: checkmark.circle.fill); RoundedRectangle with green stroke for selected card
- **Data:** Same FastingPlan list; selectedPlanId = 14h; toast message string
- **Interactions:** Selecting the 14h card moves the green border/checkmark to it, fires the '14h goal set' toast, and reveals its Settings button; toast auto-dismisses

### Fasting Goal Detail - Start Time Picker (14h) [pro_screen_105.webp] (free)
- **Purpose:** Configure the selected 14h plan: pick the fasting start time, preview computed end time, and toggle fasting notifications.
- **UI:** Back chevron + title 'Fasting goal'; Large headline '14h'; Subtitle '14:10 plan â€” fast for 14 hours and eat within 10 to support fat burning and balance.'; Card with label 'Select you fasting start time'; Wheel/clock picker columns showing hours (7,8,9,10,11), minutes (58,59,00,01,02), AM/PM; centered selection '9 : 00 PM' in bold; Computed text 'Based on your start time fasting will end:' and bold 'Wed, Aug 27, 11:00 AM'; Notification row: bell icon + 'Get notified when your fasting starts and ends' with a green Toggle (on); Bottom pill button 'Your current goal âœ“' (disabled/confirmed state); Home indicator
- **iOS:** NavigationStack; DatePicker(.wheel) or custom Picker columns for hour/minute/AM-PM; VStack with computed end-time Text; Toggle with green tint inside a card row; Capsule confirmation button (disabled style)
- **Data:** selectedPlan.hours=14; fastingStartTime (Date/time components); derived fastingEndTime; notificationsEnabled Bool
- **Interactions:** Scroll the wheel picker to change start time -> end time recomputes live; toggle notifications on/off; button reflects current goal already set; back to return

### Start Fasting - Include Last Meal Sheet [pro_screen_106.webp] (free)
- **Purpose:** Bottom sheet prompting whether to backdate the fast start to the last logged meal time before starting a new fast.
- **UI:** Background: Home with 'Today' header, day nav chevrons, daytime sky scene with peeking raccoon mascot; Bottom sheet with grabber; Small meal thumbnail (beverage/jar) with green refresh badge; Headline 'Include the last 1m in your fasting?' ('1m' in green); Subtext 'Your last meal log was at 10:57 AM. Start fast from then or choose different time.'; Wheel picker with day column (Sun, Aug 24 / Yesterday / Today selected / future), hour, minute, AM/PM; centered bold 'Today 10 57 AM'; Dark pill primary button 'Start fasting from 10:57 AM'; Home indicator
- **iOS:** .sheet / .presentationDetents bottom sheet; Wheel Picker columns (relative day + time); AsyncImage thumbnail with badge overlay; Capsule primary Button (black)
- **Data:** lastMealLog {name, time 10:57 AM, thumbnail}; chosen fastStartDate; relative day options
- **Interactions:** Adjust picker to choose backdated start; tap 'Start fasting from 10:57 AM' to begin the fast; swipe down to dismiss

### End Fasting - Under 12h Warning (full screen) [pro_screen_108.webp] (free)
- **Purpose:** Full-screen confirmation when ending a fast shorter than 12h, warning it won't count for fat-burning and offering to keep fasting or cancel.
- **UI:** Close (X) button top-left; Large worried/yawning raccoon mascot illustration; Warning icon (amber !) + duration '11h 56m'; Body text 'Less than 12h isn't enough for fat-burning. Keep going so we can save this fast for you.'; Detail card: 'Start' = 'Mon 25, 11:02 PM'; 'End' = 'Tue 26, 10:58 AM' with edit pencil; Red text link 'Cancel current fast'; Dark pill primary button 'Keep fasting'; Home indicator
- **iOS:** Full-screen cover / sheet; Image mascot asset; HStack warning Label (Image systemName exclamationmark.circle.fill) + big Text; Grouped card with Start/End rows; Capsule Button 'Keep fasting' (black); Plain destructive Button 'Cancel current fast' (red text)
- **Data:** endingFast {duration 11h56m, start 'Mon 25 11:02 PM', end 'Tue 26 10:58 AM'}; minFatBurnHours=12
- **Interactions:** Tap 'Keep fasting' or X to dismiss and continue; tap pencil to edit end time; tap 'Cancel current fast' -> opens cancel confirmation sheet (screen 109)

### Cancel Current Fast - Confirmation Sheet [pro_screen_109.webp] (free)
- **Purpose:** Destructive confirmation bottom sheet to remove the current fast from the log so it won't count toward stats.
- **UI:** Dimmed under-12h warning screen behind (mascot, '11h 57m', start/end card); Close (X) top-left on dimmed layer; Bottom sheet with grabber; Title 'Want to cancel current fast?'; Subtext 'Remove this fast from your log? It won't count toward your stats.'; Red filled pill button 'Cancel current fast'; White outlined pill button 'Go back'; Home indicator
- **iOS:** confirmationDialog or custom .sheet with detent; Dimmed background overlay; Capsule destructive Button (red filled); Capsule secondary Button (outlined 'Go back')
- **Data:** currentFast reference to delete; affects stats/streak
- **Interactions:** Tap 'Cancel current fast' -> deletes fast and shows success toast (screen 110); tap 'Go back' or swipe down to dismiss and keep fasting

### Choose Fasting Goal [pro_screen_141.webp] (free)
- **Purpose:** Pick an intermittent-fasting plan by difficulty, with a selected plan exposing extra settings.
- **UI:** Back chevron; Centered title 'Choose fasting goal'; Card '12h' with green 'Beginner' badge + description 'You probably already follow this rhythm. It's a great way to start and build the habit.'; Card '14h' (SELECTED: green border) with blue 'Intermediate' badge, green check circle top-right, description '14:10 plan -- fast for 14 hours and eat within 10 to support fat burning and balance.', plus a 'Settings' outlined button inside; Card '16h' with red 'Challenging' badge + description 'The classic 16:8 plan. Fast for 16 hours, eat within an 8-hour window to support fat burn.'; Card 'Custom' with grey 'Custom' badge + description 'Create your own fasting plan to fit your unique rhythm and lifestyle.'
- **iOS:** NavigationStack; ScrollView of large selectable card Buttons; Per-card colored badge (Capsule + Text); Selected state: green RoundedRectangle stroke + checkmark.circle.fill (green) SF Symbol; Nested outlined 'Settings' Button on selected card; Large bold Text for hour value
- **Data:** fastingPlans: [{hours, level (Beginner/Intermediate/Challenging/Custom), description}]; selected = 14h (14:10). Custom allows user-defined window.
- **Interactions:** Tap a card to select (shows green check + border). Selected card reveals 'Settings' button to configure window. 'Custom' navigates to a custom builder. Back returns to Settings.

## History/Stats (5)

### Statistics Locked / Need More Data [pro_screen_086.webp] (free)
- **Purpose:** Empty/gating state for the statistics tab telling the user they must log more days before personalized insights/stats unlock.
- **UI:** Mint-green full-screen background; Three rounded-square step indicators: first green with white checkmark (completed), two empty grey outlined squares (incomplete); Decorative green sparkle/plus confetti accents; Headline 'Log 2 more days to see statistics!' with '2 more days' emphasized in green; Subtitle 'We need data from at least 3 days to analyze your habits and provide personalized insights.'; Dark pill 'Got it!' button at bottom
- **iOS:** VStack centered; HStack of RoundedRectangle step tiles (filled vs stroked) with checkmark SF Symbol; Text with mixed-color AttributedString headline; Decorative Image sparkles; Capsule Button 'Got it!'
- **Data:** Days logged count (1 of 3 required), remaining days needed (2), unlock threshold (3 days)
- **Interactions:** Tap 'Got it!' dismisses the gate; this is an empty-state overlay for the stats tab

### Streak Celebration - 1 Day Streak [pro_screen_097.webp] (free)
- **Purpose:** Celebratory milestone screen rewarding the user for maintaining a logging streak, with a shareable badge and weekly day tracker.
- **UI:** Large red flame graphic containing the mascot wearing cool sunglasses; Big bold numeral '1' overlapping the flame; Headline 'day streak!'; Subtitle 'Building healthy eating habits with BitePal App'; Weekly day strip: Tue (active, highlighted green with a green check), Wed, Thu, Fri, Sat, Sun, Mon (inactive grey circles); Black pill 'Share' button (with share/download icon); Text-only 'Continue' button below
- **iOS:** VStack centered; ZStack (flame Image + mascot Image + Text numeral); Text headline/subtitle; HStack of day cells (each a VStack: weekday Text + circle/check); Capsule Button 'Share' (ShareLink); plain Button 'Continue'
- **Data:** Current streak count (1 day), per-weekday completion status, branding text, shareable streak card image
- **Interactions:** Tap 'Share' to export streak card; tap 'Continue' to proceed; day cells reflect logged days

### Statistics Ready - Success State [pro_screen_098.webp] (free)
- **Purpose:** Confirmation/celebration screen telling the user that enough data has been logged and their statistics/insights are now available.
- **UI:** Three overlapping green rounded-square checkmark badges (animated success icons); Headline 'Your statistics is ready!'; Subtitle 'Go and check your weekly summary & personalized insights.'; Small green confetti/spark accents scattered around; Black pill primary button 'See statistics'; Text-only secondary button 'To home'; Light mint-green background
- **iOS:** VStack centered on mint background; ZStack/HStack of RoundedRectangle check badges with spring animation; Text title + secondary subtitle; Canvas/particle confetti overlay; Capsule primary Button 'See statistics'; plain Button 'To home'
- **Data:** Flag that >=3 days of data exist, navigation targets (statistics tab, home)
- **Interactions:** Tap 'See statistics' to open the stats/insights screen; tap 'To home' to return to dashboard

### Home - Date Picker Calendar (month overlay) [pro_screen_125.webp] (free)
- **Purpose:** Calendar/date-picker overlay dropped from the Home header letting the user jump to a specific day; the dimmed Home dashboard (190 kcal) shows behind it.
- **UI:** Month header 'August 2025' with prev (<) and next (>) circular arrow buttons; Weekday header row M T W T F S S; Full month grid of dates 1-31; Today/selected date 26 highlighted in a filled black circle; Future dates (27-31) shown greyed/disabled; Dimmed background showing 'Calories eaten' card with '190 kcal', a circular '+' add button with purple progress arc, macro bars (Carbs 6, Fats 16, Proteins 7) and a small food photo thumbnail; Floating bottom tab bar visible behind dim
- **iOS:** Sheet / overlay presentation (.sheet or custom popover); DatePicker (.graphical) or custom LazyVGrid calendar; Button arrows for month change; ZStack dim overlay (Color.black.opacity); RoundedRectangle calendar card; Circle highlight for selected day
- **Data:** Current month/year (August 2025); selectable days; today/selected day (26); days with vs without logged data; disabled future dates; underlying day summary (190 kcal, macro grams, logged meal thumbnail)
- **Interactions:** Tap a date to select and dismiss overlay loading that day's log; tap < / > to change month; tap outside to dismiss; selecting future dates disabled

### Stats - Locked Empty State (Log 2 more days) [pro_screen_126.webp] (free)
- **Purpose:** Empty/locked state of the Statistics tab telling the user that statistics are unavailable until they have logged at least 3 days of data; teases the blurred charts behind.
- **UI:** Blurred preview of stats charts behind (circular ring chart, colored stat tiles in grid); Three progress squares: first filled green with white checkmark (day logged), two empty outlined squares (days remaining); Headline 'Log 2 more days to see statistics!' with '2 more days' emphasized in green; Subtext 'We need data from at least 3 days to analyze your habits and provide personalized insights.'; Decorative green sparkle/cross shapes; Bottom tab bar with Home, Stats (bar chart, active/black), Settings
- **iOS:** ZStack with blurred (.blur) placeholder chart views; VStack; HStack of RoundedRectangle progress squares with checkmark SF Symbol; Text with AttributedString/colored Text for emphasis; Decorative Image sparkles; TabView bottom bar
- **Data:** Number of distinct days logged (1 of 3 required); days remaining (2); gating threshold (3 days) to unlock statistics analytics
- **Interactions:** Mostly passive gating screen; progress squares fill as more days are logged; user must log more meals (via Home) to unlock; bottom tab navigation; statistics auto-unlock once threshold met

## Paywall (6)

### BitePal Plus Paywall - Collapsed (Most Popular plan) [pro_screen_046.webp] (pro)
- **Purpose:** Primary subscription paywall presenting the recommended annual plan with a 3-day free trial and a single-tap trial start.
- **UI:** Green gradient top with rocketing raccoon mascot (lightning-bolt eyes, white cloud/exhaust) and yellow lightning sparks; Close 'X' button top-left; 'BitePal' wordmark with green 'Plus' badge; Headline 'Achieve your goals 4.2x faster' with '4.2x' in green; Selected plan card (green outline) with green 'Most popular' badge: '3-day free trial', strikethrough/regular 'then $XX.XX + $35.99/year', price '$2.99 per month'; Disclosure 'Show more plans v'; Comparison header 'What you get' with 'free' and green 'Plus' columns; first feature row 'AI calorie counter' with green check in both columns; Sticky dark CTA 'Start my 3-day free trial'; Reassurance line 'No payment now. Easy to cancel.'
- **iOS:** ZStack with LinearGradient header; Image (mascot); Button (X dismiss); Selectable plan card (RoundedRectangle with green stroke); Badge Capsules; Comparison table (Grid/VStack rows); SF Symbol checkmark.seal.fill; Sticky Capsule CTA; DisclosureGroup / expand toggle
- **Data:** plans (annual trial: 3-day free trial then $35.99/yr, $2.99/mo equivalent), feature matrix free vs Plus, selectedPlan, trial eligibility
- **Interactions:** Tap X to dismiss; tap 'Show more plans' to expand alternative plans (screen 047); tap CTA to launch StoreKit purchase; scroll reveals feature comparison

### BitePal Plus Paywall - Expanded Plans (Weekly option) [pro_screen_047.webp] (pro)
- **Purpose:** Paywall state after tapping 'Show more plans', revealing the pay-as-you-go weekly option alongside the recommended annual trial.
- **UI:** Same green gradient header, rocketing mascot, X button, 'BitePal Plus' badge, headline 'Achieve your goals 4.2x faster'; Selected annual card (green): 'Most popular', '3-day free trial', 'then $XX.XX + $35.99/year', '$2.99 per month'; Second plan card 'Pay-as-you-go' badge: 'Weekly', subtext 'No commitment. Cancel anytime.', price '$3.99 per week'; Disclosure toggle 'Hide plans ^'; Sticky dark CTA 'Start my 3-day free trial'; Reassurance line 'No payment now. Easy to cancel.'
- **iOS:** LinearGradient header + mascot Image; Selectable plan cards (RoundedRectangle, green stroke for selected); Badge Capsules ('Most popular','Pay-as-you-go'); DisclosureGroup expand/collapse; Sticky Capsule CTA
- **Data:** plan list [annual trial $35.99/yr ($2.99/mo), weekly $3.99/wk], selectedPlanId, badge metadata
- **Interactions:** Tap a plan card to select; tap 'Hide plans' to collapse back (screen 046); tap CTA to purchase selected plan; X dismisses paywall

### BitePal Plus Paywall - Feature Comparison Table [pro_screen_048.webp] (pro)
- **Purpose:** Scrolled paywall view emphasizing what Plus unlocks versus free via a free-vs-Plus feature matrix with locks on premium rows.
- **UI:** X dismiss button; 'BitePal Plus' badge and headline 'Achieve your goals 4.2x faster'; Annual plan card (green, selected): '3-day free trial', 'then ... + $35.99/year', '$2.99 per month'; Weekly card: 'Pay-as-you-go', 'Weekly', 'No commitment. Cancel anytime.', '$3.99 per week'; 'Hide plans ^' toggle; Comparison table header 'What you get' | 'free' | green 'Plus'; Rows with check/lock icons: 'AI calorie counter' (free check + Plus check), 'Intermittent fasting' (free lock, Plus check), 'Macro balance tracker' (free lock, Plus check), 'Statistics with insights' (free lock, Plus check), 'Awards & highlights' (free lock, Plus check); Highlighted green Plus column background; Sticky dark CTA 'Start my 3-day free trial'; 'No payment now. Easy to cancel.'
- **iOS:** ScrollView; Comparison Grid/Table (rows of HStack); SF Symbols checkmark.seal.fill (green) and lock.fill (grey); Highlighted column RoundedRectangle; Plan cards; Sticky Capsule CTA
- **Data:** feature matrix: featureName, freeIncluded(bool), plusIncluded(bool); premium features = fasting, macros, stats, awards; plan pricing
- **Interactions:** Scroll to compare features; locks signal gated free features; tap CTA to start trial; X dismisses

### BitePal Plus Paywall - Testimonials & Award Badges [pro_screen_049.webp] (pro)
- **Purpose:** Lower paywall section building trust with client success stories, rating/usage award badges, and legal subscription disclosure.
- **UI:** Tail of feature table ('Statistics with insights', 'Awards & highlights' with locks/checks); Section heading 'Success stories from our clients'; Testimonial card: circular avatar, name 'Sophie' with flag emoji, stat '67 kg -> 62 kg in 1 month', quote 'I've tried so many calorie counters, but BitePal is actually different. Logging meals doesn't feel like a chore anymore!'; Carousel page-dots indicator (3 dots, middle active); Two laurel-wreath award badges: '4.7 average rating' and '1M users worldwide'; Fine-print legal paragraph about auto-renewing yearly/weekly subscription and cancellation; Footer links 'Restore purchases', 'Terms of Use', 'Privacy Notice'; Sticky dark CTA 'Start my 3-day free trial' and 'No payment now. Easy to cancel.'
- **iOS:** ScrollView; TabView (.page style) for testimonial carousel with PageControl dots; Testimonial card (RoundedRectangle, AsyncImage avatar in Circle); HStack of laurel badge Images with overlaid Text; Text (footnote legal); Link buttons (Restore/Terms/Privacy); Sticky Capsule CTA
- **Data:** testimonials [name, country flag, before/after weight, quote], averageRating 4.7, userCount 1M, legal terms text, restore/terms/privacy URLs
- **Interactions:** Swipe testimonial carousel (paged); tap footer links; 'Restore purchases' triggers StoreKit restore; tap CTA to purchase

### Native App Store Purchase Sheet (StoreKit) [pro_screen_050.webp] (pro)
- **Purpose:** System StoreKit purchase confirmation sheet invoked after tapping the trial CTA, showing the annual subscription terms and requiring biometric/side-button confirmation.
- **UI:** Dimmed paywall behind (testimonial 'Lena' with German flag partially visible); System hint overlay 'Double Click to Subscribe' (right edge); Native sheet titled 'App Store' with close X; App icon (raccoon) with 'Annual Subscription', 'BitePal: AI Calorie Tracker', 'Subscription'; '3-day free trial' / 'Starting today'; '$35.99 per year' / 'Starting Aug 28, 2025'; Fine print 'No commitment. Cancel anytime in Settings >', 'Apple Account at least a day before each renewal date. Plan automatically renews until canceled.'; 'Account: <user email>'; Apple double-click confirmation glyph and 'Confirm with Side Button'
- **iOS:** StoreKit2 product subscription sheet (system-presented, not custom); Underlying dimmed app view (ZStack overlay); System payment sheet UI (cannot be customized; invoked via Product.purchase())
- **Data:** StoreKit product: annual subscription, introductory 3-day free trial, price $35.99/year, renewal date, Apple Account email
- **Interactions:** User double-clicks the side button (Face ID) to confirm purchase; close X cancels; on success proceeds to confirmation alert (screen 051)

### Purchase Success Confirmation Alert [pro_screen_051.webp] (pro)
- **Purpose:** Confirms the subscription purchase succeeded, after which the user proceeds out of the paywall into account creation.
- **UI:** Dimmed paywall background (testimonials 'Success stories from our clients', Sophie card, 4.7 / 1M award badges, footer links); Native-style alert 'You're all set.' with body 'Your purchase was successful.' and a single blue 'OK' action; Sticky dark CTA 'Start my 3-day free trial' still visible behind
- **iOS:** Underlying paywall view (blurred/dimmed); Alert (.alert modifier) or custom centered confirmation card with Button('OK')
- **Data:** purchase result state (success), entitlement now active (Plus)
- **Interactions:** Tap 'OK' to dismiss the alert; app unlocks Plus entitlement and advances to account creation (screen 052)

## Settings (20)

### Customization - Background Picker [pro_screen_100.webp] (unknown)
- **Purpose:** Customization sheet for changing the pet's home-screen background scene; the mascot updates live in the preview above the picker grid.
- **UI:** 'Today' header with dropdown and date arrows (< >) at top, with the live forest scene + raccoon mascot preview; Bottom sheet with segmented tabs 'Background' (selected) and 'App Icon', plus a page dot; 3-column grid of selectable background thumbnails: row1 = current forest scene (selected, with checkmark/edit badge), blue-sky/yellow-field scene, pink Christmas-tree scene; row2 = Halloween pumpkins/fence night scene, rainbow scene, mountains-with-sun scene; row3 = palm trees beach, sunrise/ocean sunset, floral sunset; Selected thumbnail has a dark rounded border with a check/edit badge
- **iOS:** Custom illustrated header preview; Sheet/bottom drawer (presentationDetents); Picker / segmented control (Background | App Icon) or custom tab; LazyVGrid (3 columns) of thumbnail Buttons (RoundedRectangle images); Selection overlay badge (checkmark.circle / pencil); Page indicator dot
- **Data:** Available background themes catalog, currently selected background id, (some themes may be premium/seasonal - lock status not visible), live preview binding
- **Interactions:** Tap a thumbnail to apply a new background (updates preview instantly); swipe between 'Background' and 'App Icon' tabs; scroll grid for more options

### Customization - App Icon Changed Confirmation [pro_screen_101.webp] (unknown)
- **Purpose:** App Icon customization with the iOS system alert confirming the home-screen icon was changed for BitePal. Shown over the App Icon picker grid.
- **UI:** 'Today' header (blue sky + yellow field background with the mascot); System UIAlertController-style dialog: small new icon preview thumbnail, text 'You have changed the icon for "BitePal".', and blue 'OK' button; Behind the alert: grid of selectable alternate raccoon-face app icon tiles (5 visible: winking mad face, squinting smile, side-eye, blushing happy face, and a selected/outlined monocle face icon)
- **iOS:** UIAlertController / .alert system dialog (triggered by setAlternateIconName); LazyVGrid of app-icon option Buttons (RoundedRectangle images); Selection stroke overlay on chosen icon; Illustrated header preview
- **Data:** Alternate app icon catalog, selected alternate icon name, system confirmation result
- **Interactions:** Selecting an icon calls UIApplication setAlternateIconName, triggering the system alert; tap 'OK' to dismiss the confirmation

### Customization - App Icon Picker [pro_screen_102.webp] (unknown)
- **Purpose:** App Icon tab of the customization sheet, letting the user pick an alternate BitePal home-screen icon featuring different raccoon expressions.
- **UI:** 'Today' header preview with blue sky / yellow field background and the mascot (live preview); Date arrows (< >); Bottom sheet segmented tabs: 'Background' (inactive grey) and 'App Icon' (active/bold), with a page dot; Grid of 5 alternate app-icon tiles: winking grumpy face, squinting happy/smug face, side-eye skeptical face, blushing open-mouth happy face, and a monocle/surprised face (the last shown selected with a dark outlined border)
- **iOS:** Sheet (presentationDetents); Segmented Picker / custom tab control; LazyVGrid (3 columns) of app-icon Buttons (RoundedRectangle thumbnails); Selection border overlay; Illustrated header preview
- **Data:** Alternate app icon asset catalog, currently selected icon id, live preview state
- **Interactions:** Tap an icon tile to select/apply it (triggers system change + confirmation alert); swipe/tap to switch back to 'Background' tab

### Settings - Main (Personal plan, Account, Application) [pro_screen_127.webp] (free)
- **Purpose:** Main Settings screen showing the user's calorie/macro plan summary and entry points to edit plan, manage account, and app preferences.
- **UI:** Large title 'Settings'; 'Your personal plan' card: flame icon with '1,283 Calories'; three macro ring charts: Carbs 40% (yellow), Fats 30% (blue), Proteins 30% (green); 'Edit plan' section rows with chevrons: 'Calories' (flame icon), 'Macro balance' (multicolor pie icon), 'Recalculate plan' (blue refresh icon); 'Account' section rows: 'Email  screensdesignstest@gmail.com' (envelope icon), 'Personal details' (green person icon, chevron), 'Eating preferences' (cutlery icon, chevron); 'Application' section beginning: 'Daily ...' row with green toggle switch (ON), partial 'Fasting' row; Bottom tab bar with Home, Stats, Settings (gear, active)
- **iOS:** NavigationStack with large title; List / Form or ScrollView with grouped card sections; Custom ring charts (Circle trim) for macros; HStack rows with SF Symbol icons and chevron disclosure; Toggle (green switch); Custom floating tab bar
- **Data:** Personal plan: daily calorie target (1,283 kcal); macro split percentages (Carbs 40 / Fats 30 / Proteins 30); account email; personal details; eating preferences; application toggles (daily reminders ON), fasting settings
- **Interactions:** Tap Calories / Macro balance / Recalculate plan to edit plan; tap Email to copy; tap Personal details / Eating preferences to drill in; toggle daily notification switch; scroll for more app settings; bottom tab navigation

### Edit Plan - Calories (numeric entry with keypad) [pro_screen_128.webp] (free)
- **Purpose:** Edit-plan detail screen for setting the daily calorie goal via a large numeric input and on-screen keypad.
- **UI:** Nav bar: back chevron (<) and centered title 'Calories'; Prompt 'Enter kcal amount'; Large value display: red flame icon + '1,300' with a text caret; Black pill primary button 'Update calories'; Full-width numeric keypad (1-9, 0, delete/backspace key) styled like iOS keypad with ABC/DEF letter subtitles
- **iOS:** NavigationStack with back button; VStack; Large Text bound to TextField/numeric state; SF Symbol flame; Button (black Capsule) 'Update calories'; Custom numeric keypad view (LazyVGrid of buttons) or TextField with .keyboardType(.numberPad)
- **Data:** Editable daily calorie target value (current 1,300 kcal); validation of numeric input; writes back to personal plan calorie limit
- **Interactions:** Tap keypad digits to edit value; backspace to delete; tap 'Update calories' to save and return (triggers confirmation toast on Settings); back chevron cancels

### Settings - Plan Updated Confirmation Toast [pro_screen_129.webp] (free)
- **Purpose:** Settings main screen after saving a calorie change, showing a green success toast and the updated plan value (now 1,300 calories).
- **UI:** Green success toast banner at top: checkmark icon + 'Personal plan limits has been updated'; Partial 'Settings' title behind toast; 'Your personal plan' card now showing flame '1,300 Calories' with macro rings Carbs 40%, Fats 30%, Proteins 30%; 'Edit plan' rows: Calories, Macro balance, Recalculate plan (with chevrons); 'Account' rows: Email screensdesignstest@gmail.com, Personal details, Eating preferences; 'Application' section start with green toggle (ON) and partial Fasting row; Bottom tab bar with gear (Settings) active
- **iOS:** Toast/overlay view (Capsule with green background + SF Symbol checkmark, auto-dismiss); Same Settings List/ScrollView structure; Ring chart views; Toggle; Floating tab bar
- **Data:** Confirmation message state; updated calorie target (1,300); macro split (40/30/30); same account/app settings as Settings main
- **Interactions:** Toast auto-dismisses after a few seconds; rest of screen behaves like Settings main (tap rows to edit, toggle switches, navigate tabs)

### Edit Plan - Macro Balance (sliders) [pro_screen_130.webp] (free)
- **Purpose:** Edit-plan detail screen for adjusting macronutrient percentage split via sliders, with a live donut chart enforcing a total of 100%.
- **UI:** Nav bar: back chevron (<) and centered title 'Macro balance'; Large multicolor donut/ring chart (green/yellow/blue segments) with center text '100%'; Caption 'Macronutrients must equal 100%'; White card with three slider rows: 'Carbs  40% Â· 130g Â· 520 kcal' (yellow slider with - and + steppers), 'Fats  30% Â· 43g Â· 390 kcal' (blue slider), 'Proteins  30% Â· 98g Â· 390 kcal' (green slider), each with minus/plus stepper buttons at the ends; Black pill primary button 'Update macro balance'
- **iOS:** NavigationStack with back button; Custom donut chart (multiple Circle trims) with centered Text; Three custom Slider views (tinted) each with leading/trailing Stepper/Button (- / +); RoundedRectangle card; Button (black Capsule) 'Update macro balance'
- **Data:** Macro split percentages (Carbs 40%, Fats 30%, Proteins 30%) with derived grams and kcal per macro based on calorie target; constraint that percentages sum to 100%; writes back to personal plan macro balance
- **Interactions:** Drag sliders or tap +/- steppers to adjust each macro; donut chart and gram/kcal values update live; total must equal 100% to enable save; tap 'Update macro balance' to save; back chevron cancels

### Settings - Email Copied Confirmation Toast [pro_screen_132.webp] (free)
- **Purpose:** Settings main screen showing a green success toast confirming the account email was copied to clipboard after tapping the Email row.
- **UI:** Green success toast banner: checkmark icon + 'Email copied to clipboard'; Partial 'Settings' title behind toast; 'Your personal plan' card: flame '1,300 Calories', macro rings Carbs 40%, Fats 30%, Proteins 30%; 'Edit plan' rows: Calories, Macro balance, Recalculate plan (chevrons); 'Account' rows: Email screensdesignstest@gmail.com, Personal details, Eating preferences; 'Application' section start with green toggle (ON), partial Fasting row; Bottom tab bar with Settings (gear) active
- **iOS:** Toast/overlay view (green Capsule + checkmark SF Symbol, auto-dismiss); Settings List/ScrollView with grouped cards; Ring chart views; Toggle; Floating tab bar; UIPasteboard for copy action
- **Data:** Clipboard copy confirmation state; account email (screensdesignstest@gmail.com); plan summary (1,300 kcal, 40/30/30 macros); same settings rows
- **Interactions:** Tapping the Email row copies the address and shows this toast; toast auto-dismisses; other rows behave like Settings main; bottom tab navigation

### Personal Details [pro_screen_133.webp] (free)
- **Purpose:** Read-only summary of the user's profile (physical attributes and weight goal) with each row tappable to edit the underlying value.
- **UI:** Back chevron (top-left); Centered nav title 'Personal details'; White rounded card 1 - section header 'Physical attributes'; Row 'Gender' -> 'Female' with chevron; Row 'Age' -> '26' with chevron; Row 'Height' -> '151 cm' with chevron; Row 'Activity level' -> 'Lightly active' with chevron; White rounded card 2 - section header 'Weight'; Row 'Current' -> '57 kg' with chevron; Row 'Target' -> '50 kg' with chevron; Row 'Pace' -> '0.8 kg per week' with chevron
- **iOS:** NavigationStack; NavigationLink (back button + per-row drill-in); List / Form with .insetGrouped grouping OR custom VStack of rounded cards; Section with header text; HStack rows with Spacer and chevron.right SF Symbol; Text labels with secondary foreground color for values
- **Data:** UserProfile: gender (enum), age (Int), height (value + unit cm/ft), activityLevel (enum), currentWeight (kg), targetWeight (kg), pace (kg per week). Values shown: Female, 26, 151 cm, Lightly active, 57 kg, 50 kg, 0.8 kg/week.
- **Interactions:** Tap any row to push the corresponding editor (gender picker 134, age picker 135, height picker 136, etc.). Back chevron pops to Settings.

### Eating Preferences [pro_screen_137.webp] (free)
- **Purpose:** Read-only summary of the user's eating window, meal frequency, and excluded products, with edit affordances.
- **UI:** Back chevron; Centered title 'Eating preferences'; Card 1 header 'Eating window'; Row 'First meal' -> '5:30 AM'; Row 'Last meal' -> '9:00 PM' (the two meal rows share one chevron at right); Row 'Meals per day' -> '3' with chevron; Card 2 header 'Products I don't eat' with 'Edit' pill button at right; List item 'Gluten'; Divider; List item 'Dairy'
- **iOS:** NavigationStack; Grouped rounded cards (List .insetGrouped or custom VStack); Section headers; HStack rows with value + chevron.right; Small 'Edit' Button styled as a grey capsule; Divider between excluded-product rows
- **Data:** eatingWindow: firstMeal 5:30 AM, lastMeal 9:00 PM; mealsPerDay = 3; excludedProducts = [Gluten, Dairy].
- **Interactions:** Tap eating-window rows to open time editor (138). Tap 'Meals per day' to edit count. Tap 'Edit' to open product exclusion picker (139). Back returns.

### Settings (Main) [pro_screen_140.webp] (free)
- **Purpose:** Root settings hub grouping app preferences, support links, and community/social links; includes the floating bottom tab bar.
- **UI:** Large bold title 'Settings'; Card 'Application' section: 'Daily reminder' (blue bell icon) with green ON toggle; 'Fasting' (red clock icon) chevron; 'Calories display' (green icon) chevron; 'Measurement system' (red icon) chevron; 'Raccoon's name' (icon) -> value 'Bubba' with chevron; Card 'Support' section: 'Feedback & Help' (red heart) chevron; 'Rate on App Store' (gold star) chevron; Card 'Community' section: 'TikTok' (TikTok glyph); 'Instagram' (IG glyph); 'X (Former...' (X/Twitter bird glyph); Partial 'Other' section beginning at bottom; Floating pill tab bar overlay: home icon, bar-chart/stats icon, gear/settings icon (active, dark)
- **iOS:** NavigationStack with large title; List .insetGrouped or custom card VStacks; Toggle (green) for Daily reminder; NavigationLink rows with leading SF Symbol icons in colored rounded badges; Trailing value Text ('Bubba') + chevron; Link / openURL rows for social with brand glyphs; Custom floating TabBar (Capsule background with HStack of tab Buttons)
- **Data:** Settings: dailyReminder Bool (on); fasting config; caloriesDisplay mode; measurementSystem; raccoonName String ='Bubba'; support links; social URLs (TikTok, Instagram, X).
- **Interactions:** Toggle daily reminder. Tap Fasting -> 141, Calories display -> 142, Measurement system, Raccoon's name editor. Support rows open help/App Store. Social rows open external apps/URLs. Tab bar switches Home/Stats/Settings.

### Calories Display Mode [pro_screen_142.webp] (free)
- **Purpose:** Choose how the calorie ring presents progress: remaining (left/over) vs consumed (eaten).
- **UI:** Back chevron; Centered title 'Calories display'; Preview card with two example rings: left ring '0 / Kcal eaten' (empty grey track); right ring '1,310 / Kcal eaten' (orange progress arc with a small red over-budget segment at top); Option row 'Display calories left/over' with empty radio (unselected); Divider; Option row 'Display calories eaten' with filled green radio (selected)
- **iOS:** NavigationStack; Card containing two ring previews (Circle + trimmed Circle stroke for progress, ZStack with centered Text); List of mutually-exclusive options using custom radio buttons (circle / checkmark.circle.fill green); Divider between rows
- **Data:** caloriesDisplayMode enum {leftOver, eaten} = eaten; preview values 0 and 1,310 kcal; over-budget indicated by red ring segment.
- **Interactions:** Tap an option to switch display mode (single select, green radio). Choice updates the home calorie ring app-wide. Back returns to Settings.

### Calories Display Preference [pro_screen_143.webp] (free)
- **Purpose:** Lets the user choose how the daily calorie ring/number is presented across the app: either as calories remaining (left/over) or as calories already eaten.
- **UI:** Back chevron (top-left); Centered nav title 'Calories display'; White rounded card containing two preview rings side by side; Left preview ring: grey/empty ring with '0' and 'Kcal eaten' label; Right preview ring: orange progress ring (with small red overflow segment at top) showing '1,310' and 'Kcal eaten'; Option row 'Display calories left/over' with empty (unselected) radio on right; Divider line; Option row 'Display calories eaten' with green filled radio (selected) on right
- **iOS:** NavigationStack with toolbar back button; Form/List or VStack inside a card (RoundedRectangle background); Two custom ring previews built with Circle().trim + .stroke (or Gauge); Custom radio-style selection rows; could use a Picker(.inline) or tappable HStack with SF Symbol 'circle'/'checkmark.circle.fill'; @State / @AppStorage enum binding for the display mode
- **Data:** Enum displayMode {.left, .eaten}; sample preview values: caloriesEaten=1310, caloriesGoal used to compute ring fill and overflow.
- **Interactions:** Tap a row to select that display mode (radio toggles, mutually exclusive); preview rings illustrate each choice; back chevron returns to Settings. Selection persists.

### Measurement System & Ingredient Units [pro_screen_144.webp] (free)
- **Purpose:** Lets the user pick a unit system (Metric vs Imperial) and toggle which ingredient measurement units are available/shown when logging or editing food.
- **UI:** Back chevron (top-left); Centered nav title 'Measurement system'; First card: 'Metric' (subtitle 'Kilograms, grams, liters, milliliters, etc') with green filled radio selected; divider; 'Imperial' (subtitle 'Ounces, pounds, pints, etc') with empty radio; Second card header 'Units for ingredients'; Toggle rows: 'Grams (g)' ON (green), 'Slices' OFF, 'Cups' OFF, 'Pieces' OFF, 'Tablespoons (tbsp)' OFF, 'Teaspoons (tsp)' OFF; Dividers between each toggle row
- **iOS:** NavigationStack with back button; Two grouped Sections in a List/Form, each rendered as a white rounded card; Radio-style selection rows for Metric/Imperial (Picker or custom HStack with SF Symbol); Toggle (SwiftUI) with green tint for each ingredient unit; @AppStorage for measurementSystem enum and a Set<IngredientUnit> for enabled units
- **Data:** measurementSystem enum {metric, imperial}; ingredientUnits dictionary/Set of bools: grams=true, slices=false, cups=false, pieces=false, tablespoons=false, teaspoons=false.
- **Interactions:** Tap Metric/Imperial radio to switch system (mutually exclusive); flip individual toggles to enable/disable ingredient units; changes persist and affect food logging UI; back returns to Settings.

### Name Your Raccoon (Mascot Naming) [pro_screen_145.webp] (free)
- **Purpose:** Onboarding/personalization screen where the user names the app's raccoon mascot; current name is 'Bubba'.
- **UI:** Back chevron (top-left); Large grey raccoon mascot illustration peeking from top-right corner; Centered helper label 'Name your raccoon'; Large bold editable name 'Bubba' centered; Dark pill button at bottom with checkmark and 'Done' text
- **iOS:** NavigationStack with back button; Image (mascot asset) positioned with offset/overlay; TextField centered with large bold font (no border) for the name input; @State string for raccoonName; Capsule/Button styled dark for 'Done' with Label (checkmark SF Symbol + text); Keyboard handling / focus state
- **Data:** raccoonName string (current value 'Bubba'); mascot image asset.
- **Interactions:** Tap the name to edit via keyboard; tap 'Done' to save and dismiss/return; back chevron cancels. Likely autofocus on the text field.

### Settings (Main) [pro_screen_146.webp] (free)
- **Purpose:** Root settings screen with community links, legal/about info, account version, and destructive account actions.
- **UI:** Large bold title 'Settings'; Card section 'Community': row 'Instagram' with Instagram icon; divider; row 'X (Formerly Twitter)' with X/bird icon; Card section 'Other': 'Privacy Notice' with chevron; 'Terms of service' with chevron; 'Nutrition advice sources' with chevron; 'App version' with value '1.15.5.208' (no chevron); Red text row 'Delete my account'; Greyed device/install ID string below card; Outlined pill 'Log out' button; Bottom tab bar with three icons: Home (house), Stats (bar chart), Settings (gear, active)
- **iOS:** NavigationStack with large title; List/Form with grouped Sections rendered as rounded cards; HStack rows with SF Symbols / brand icons and trailing chevron (NavigationLink); Label rows opening Safari/SFSafariViewController for legal pages; Button with destructive role (red) for Delete; bordered Capsule Button for Log out; TabView with custom tab bar (house, chart.bar, gearshape SF Symbols)
- **Data:** Social URLs (Instagram, X); legal page URLs; appVersion string '1.15.5.208'; device/install ID string; current user/account for delete/logout.
- **Interactions:** Tap social rows to open external apps/URLs; tap legal rows to push web views; tap App version to copy (see screen 148); tap 'Delete my account' to open termination confirmation sheet; tap 'Log out' to open logout confirmation sheet; tab bar switches between Home/Stats/Settings.

### Privacy Notice (In-App Web View) [pro_screen_147.webp] (free)
- **Purpose:** Displays BitePal's Privacy Notice document in an in-app browser opened from Settings.
- **UI:** Safari-style top bar: 'Done' button (blue, left), centered address/title 'bitepal.app', reader and reload icons (right); Heading 'Privacy Notice'; 'Effective as of: April 29, 2024'; Body paragraphs referencing 'Reface Lithuania UAB d/b/a BitePal', GDPR, CCPA, CPRA; Numbered section '1. Scope' with paragraph mentioning the App and Site https://quiz.bitepal.app/ and 'Services'; Numbered section '2. Changes to our Privacy Notice'; Bottom Safari toolbar: back/forward chevrons, share icon, open-in-Safari compass icon
- **iOS:** SFSafariViewController (or WKWebView wrapped in UIViewRepresentable) presented modally; Native Safari chrome (Done, address bar, reader, share, navigation); Loaded remote HTML legal content
- **Data:** Remote URL to privacy notice (bitepal.app); rendered web document content.
- **Interactions:** Scroll the document; tap 'Done' to dismiss back to Settings; use Safari controls (reload, reader, share, back/forward, open in Safari).

### Settings with 'App version copied' Toast [pro_screen_148.webp] (free)
- **Purpose:** Same Settings root screen showing a confirmation toast after the user tapped the App version row to copy it to the clipboard.
- **UI:** Partially hidden 'Settings' title behind toast; Green rounded toast at top with check icon and text 'App version copied to clipboard'; Same Community card (Instagram, X); Same Other card (Privacy Notice, Terms of service, Nutrition advice sources, App version 1.15.5.208, Delete my account in red); Greyed device ID string; Log out outlined pill button; Bottom tab bar (Home, Stats, Settings active)
- **iOS:** Same NavigationStack/List as screen 146; Custom transient toast overlay (Capsule with green fill, SF Symbol checkmark + Text) animated in/out with .transition and a timed dismissal; UIPasteboard.general.string = appVersion on tap
- **Data:** appVersion '1.15.5.208' copied to clipboard; toast message string.
- **Interactions:** Tapping the App version row copies the version and shows the green success toast, which auto-dismisses after a short delay; all other Settings interactions remain available.

### Delete Account Confirmation Sheet [pro_screen_149.webp] (free)
- **Purpose:** Destructive confirmation bottom sheet asking the user to confirm permanent account termination.
- **UI:** Dimmed/blurred Settings screen behind; Bottom sheet with grabber handle; Title 'Sure you want to terminate your account?'; Large solid red pill button 'Terminate'; Outlined/white pill button 'Cancel'
- **iOS:** .sheet or .confirmationDialog presentation (custom bottom sheet with presentationDetents); Title Text; Button with destructive role styled as red Capsule for 'Terminate'; Bordered Capsule Button for 'Cancel'; Dimmed background overlay
- **Data:** Current account/user id to delete; triggers account deletion API call on confirm.
- **Interactions:** Tap 'Terminate' to permanently delete the account (irreversible action); tap 'Cancel' or swipe down to dismiss and return to Settings.

### Log Out Confirmation Sheet [pro_screen_150.webp] (free)
- **Purpose:** Confirmation bottom sheet asking the user to confirm logging out, with a playful mascot message.
- **UI:** Dimmed/blurred Settings screen behind; Bottom sheet with grabber handle; Title 'Sure you want to log out?'; Subtitle 'Bubba will miss you a lot' (references the named mascot); Large solid red pill button 'Log out'; Outlined/white pill button 'Cancel'
- **iOS:** .sheet/.confirmationDialog custom bottom sheet with presentationDetents; Title + subtitle Text stack; Button (red Capsule) 'Log out'; bordered Capsule 'Cancel'; Dimmed background overlay; Uses raccoonName ('Bubba') in copy
- **Data:** raccoonName 'Bubba' for the subtitle; current session/auth token to clear on logout.
- **Interactions:** Tap 'Log out' to sign out and return to auth/login; tap 'Cancel' or swipe down to dismiss and stay logged in.

