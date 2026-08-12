# UI/UX DESIGN GUIDELINES

> A practical design system and UX guideline for creating modern, usable, accessible, scalable, and production-ready digital products.

**Version:** 1.0
**Purpose:** Product UI/UX Design Standard
**Applies to:** Mobile Apps, Web Apps, Dashboards, SaaS, Admin Panels, Landing Pages
**Platforms:** Flutter, React, React Native, Web, iOS, Android

---

# 1. DESIGN PHILOSOPHY

Every interface should follow these principles:

1. **Simple**
2. **Clear**
3. **Consistent**
4. **Useful**
5. **Accessible**
6. **Responsive**
7. **Predictable**
8. **Fast**
9. **Forgiving**
10. **Scalable**

### Core Rule

> **Do not design screens. Design user journeys.**

A beautiful screen is not enough if users cannot understand:

* Where they are
* What they can do
* What they should do next
* What happened after an action
* How to recover from a mistake

---

# 2. UX PRIORITY ORDER

When making a design decision, prioritize:

```text
1. User Goal
       ↓
2. Usability
       ↓
3. Accessibility
       ↓
4. Information Hierarchy
       ↓
5. Consistency
       ↓
6. Performance
       ↓
7. Visual Quality
       ↓
8. Decoration
```

Never sacrifice usability merely to make an interface visually attractive.

---

# 3. USER-FIRST DESIGN

Before designing any screen, answer:

### User

* Who is using this?
* What is their technical knowledge?
* What device are they using?
* What problem are they trying to solve?

### Goal

* What is the primary task?
* What is the most important action?
* What information does the user need?

### Context

* Where will they use the product?
* Are they in a hurry?
* Is the task frequent or occasional?
* Is the task sensitive or high-risk?

### Success

Define what successful completion looks like.

Example:

```text
Bad:
Design a booking page.

Good:
Allow a user to select a service, choose an available date,
select a time slot, confirm the booking, and clearly understand
that the booking was successful.
```

---

# 4. INFORMATION ARCHITECTURE

Organize information according to how users think, not how the database is structured.

## Rules

* Group related information.
* Keep categories meaningful.
* Avoid unnecessary nesting.
* Use familiar terminology.
* Keep navigation predictable.
* Put frequently used actions closer to the user.
* Reduce the number of decisions required.

### Recommended hierarchy

```text
Product
├── Primary Navigation
│   ├── Home
│   ├── Main Feature
│   ├── Activity
│   └── Profile
│
├── Secondary Navigation
│   ├── Settings
│   ├── Help
│   └── About
│
└── Contextual Actions
    ├── Edit
    ├── Delete
    ├── Share
    └── More
```

---

# 5. USER FLOW DESIGN

Before creating high-fidelity UI, create the flow.

Example:

```text
Login
  ↓
Dashboard
  ↓
Select Service
  ↓
Select Date
  ↓
Select Time
  ↓
Review
  ↓
Payment
  ↓
Success
```

For every flow, define:

* Entry point
* User goal
* Required information
* Primary action
* Secondary action
* Success state
* Failure state
* Empty state
* Loading state
* Recovery path

---

# 6. THE ONE PRIMARY ACTION RULE

Every important screen should have one clearly identifiable primary action.

### Good

```text
Heading
Description

[ Primary Action ]

Secondary option
```

### Bad

```text
[Save] [Submit] [Continue] [Next] [Confirm] [Create]
```

Too many equally prominent actions create decision fatigue.

---

# 7. VISUAL HIERARCHY

Users should immediately understand what is most important.

Use:

1. Size
2. Weight
3. Position
4. Contrast
5. Spacing
6. Color
7. Grouping

### Recommended hierarchy

```text
Page Title
    ↓
Section Heading
    ↓
Supporting Information
    ↓
Primary Content
    ↓
Secondary Content
    ↓
Metadata
```

Do not make every element visually loud.

---

# 8. GRID SYSTEM

Use a consistent layout grid.

### Mobile

Recommended:

```text
Screen width
│
├── 16px minimum horizontal padding
│
├── Content
│
└── 16px minimum horizontal padding
```

Typical values:

```text
Mobile:
16px / 20px / 24px horizontal padding

Tablet:
24px / 32px

Desktop:
32px / 40px / 48px
```

For large desktop layouts, use a maximum content width.

Example:

```text
max-width: 1200px
```

Avoid allowing content to stretch infinitely across large screens.

---

# 9. SPACING SYSTEM

Use a consistent spacing scale.

Recommended base unit:

```text
4px
```

### Spacing scale

```text
4px   → Tiny
8px   → Small
12px  → Compact
16px  → Standard
20px  → Medium
24px  → Large
32px  → Section
40px  → Large Section
48px  → Major Section
64px  → Page Section
80px  → Hero / Major Separation
```

### Rule

Do not randomly use:

```text
13px
17px
19px
23px
27px
```

unless there is a specific reason.

Consistency is more important than arbitrary precision.

---

# 10. TYPOGRAPHY

Typography should create hierarchy, not decoration.

## Recommended hierarchy

```text
Display
48–64px

H1
32–40px

H2
28–32px

H3
22–24px

H4
18–20px

Body
16px

Body Small
14px

Caption
12px
```

Adjust these values according to platform and product.

### Typography rules

* Use a maximum of 1–2 font families.
* Avoid excessive font weights.
* Maintain readable line height.
* Do not use all caps for large amounts of text.
* Avoid very small body text.
* Keep paragraphs reasonably narrow.

### Recommended line height

```text
Heading:
1.1 – 1.3

Body:
1.4 – 1.7
```

---

# 11. COLOR SYSTEM

Never select colors randomly for individual components.

Create semantic colors.

## Example

```text
Primary
Secondary
Background
Surface
Text Primary
Text Secondary
Border
Success
Warning
Error
Info
Disabled
```

Example:

```text
Primary      → Brand action
Secondary    → Supporting action
Success      → Completed / positive
Warning      → Attention required
Error        → Failure / destructive action
Info         → Informational message
```

---

# 12. COLOR USAGE RULE

Color should communicate meaning.

Do not use:

```text
Red = random decoration
Green = random decoration
Yellow = random decoration
```

Instead:

```text
Red    → Error / destructive
Green  → Success
Yellow → Warning
Blue   → Information
```

Brand colors can be used for visual identity, but semantic meaning should remain consistent.

---

# 13. CONTRAST

Text must remain readable against its background.

Avoid:

```text
Light Gray text
+
White background
```

Prefer sufficient contrast for:

* Body text
* Buttons
* Form labels
* Icons
* Important metadata
* Error messages

Do not communicate information through color alone.

Example:

```text
❌ Red text only

✓ Red icon + "Payment failed"
```

---

# 14. DARK MODE

Dark mode should not simply invert colors.

### Avoid

```text
White background → Black
Black text       → White
```

Instead use:

```text
Dark Background
Dark Surface
Elevated Surface
Primary Text
Secondary Text
Borders
Semantic Colors
```

Recommended concept:

```text
Background
    ↓
Surface
    ↓
Elevated Surface
```

Each level should have a subtle visual distinction.

---

# 15. BUTTONS

Buttons must communicate:

* What will happen
* Which action is primary
* Whether the action is available

### Button hierarchy

```text
Primary
Secondary
Tertiary
Destructive
Text / Link
```

Example:

```text
[ Create Account ]     ← Primary

[ Continue with Google ] ← Secondary

Cancel                  ← Tertiary
```

### Button rules

* Use action-oriented labels.
* Avoid vague labels such as "OK".
* Prefer "Save Changes", "Book Appointment", "Create Account".
* Keep button sizes consistent.
* Make touch targets sufficiently large.
* Provide disabled/loading states.

---

# 16. BUTTON STATES

Every interactive component should have states.

```text
Default
Hover
Focus
Pressed
Loading
Disabled
Success
Error
```

Example:

```text
Default:
[ Continue ]

Loading:
[ ◌ Processing... ]

Success:
[ ✓ Completed ]

Error:
[ Try Again ]
```

---

# 17. FORMS

Forms should minimize user effort.

## Rules

* Ask only for necessary information.
* Group related fields.
* Use meaningful labels.
* Use correct keyboard/input types.
* Show validation close to the relevant field.
* Preserve user input after errors.
* Explain formatting requirements.

### Example

```text
Email
[ name@example.com ]

Password
[ ••••••••• ]

[ Create Account ]
```

Avoid:

```text
Enter your email address below
Email Address
Please enter a valid email address
```

when the same information can be communicated more efficiently.

---

# 18. FORM VALIDATION

Prefer inline validation.

### Bad

User submits:

```text
❌ Something went wrong
```

### Good

```text
Email
[ invalid-email ]

⚠ Please enter a valid email address.
```

Validation should explain:

1. What is wrong
2. Why it is wrong
3. How to fix it

---

# 19. ERROR HANDLING

Errors are part of UX.

Never blame the user.

### Bad

```text
Invalid input!
```

### Better

```text
We couldn't process the payment.
Please check your payment details and try again.
```

### Every important error should provide:

```text
Problem
+
Explanation
+
Recovery Action
```

Example:

```text
Unable to load bookings

We couldn't connect to the server.

[ Try Again ]
```

---

# 20. LOADING STATES

Never leave users wondering whether something is happening.

Use:

```text
Progress Indicator
Skeleton Loading
Progressive Loading
Button Loading State
```

### Avoid

Blank screen.

### Good

```text
Loading bookings...

[ Skeleton ]
[ Skeleton ]
[ Skeleton ]
```

---

# 21. SKELETON SCREENS

Use skeleton loading when content structure is predictable.

Example:

```text
┌──────────────────────────┐
│ ██████████               │
│ ███████████████          │
│                          │
│ ███████████████████      │
└──────────────────────────┘
```

Skeletons should resemble the final layout.

---

# 22. EMPTY STATES

Empty screens should explain what happened and what users can do next.

### Bad

```text
No data
```

### Good

```text
No bookings yet

Your upcoming appointments will appear here.

[ Book an Appointment ]
```

An empty state should contain:

```text
Context
+
Explanation
+
Useful Action
```

---

# 23. SUCCESS STATES

Users should receive confirmation after important actions.

Example:

```text
✓ Booking Confirmed

Your appointment is scheduled for
12 August at 10:30 AM.

[ View Booking ]
```

Avoid making users guess whether the action succeeded.

---

# 24. CONFIRMATION DIALOGS

Use confirmation dialogs only when the action is:

* Destructive
* Irreversible
* Financial
* Security-sensitive
* Potentially harmful

Do not ask for confirmation for every small action.

### Good

```text
Delete project?

This action cannot be undone.

[ Cancel ] [ Delete ]
```

---

# 25. NAVIGATION

Navigation should answer:

> "Where am I and where can I go?"

### Mobile

Use familiar navigation patterns:

```text
Bottom Navigation
Tabs
Back Navigation
Navigation Drawer
```

### Desktop

Use:

```text
Sidebar
Top Navigation
Breadcrumbs
Tabs
```

Do not invent unusual navigation patterns without a strong reason.

---

# 26. MOBILE NAVIGATION

For apps with 3–5 major destinations:

```text
Home
Search
Activity
Notifications
Profile
```

Use bottom navigation.

Do not overload bottom navigation with 8–10 items.

---

# 27. RESPONSIVE DESIGN

Design for multiple screen sizes.

### Consider:

```text
Small Mobile
Large Mobile
Tablet
Small Desktop
Large Desktop
```

Do not simply stretch the mobile UI onto desktop.

Instead adapt:

```text
Layout
Navigation
Grid
Typography
Spacing
Content density
```

---

# 28. MOBILE-FIRST APPROACH

When designing responsive products:

```text
Mobile
   ↓
Tablet
   ↓
Desktop
```

Start with the most constrained layout.

This forces prioritization.

---

# 29. TOUCH TARGETS

Interactive elements must be easy to tap.

Avoid tiny:

```text
icons
buttons
close buttons
checkboxes
links
```

Give controls sufficient touch area even when the visible icon is small.

Example:

```text
Visible icon: 20–24px

Interactive area:
approximately 44–48px
```

---

# 30. ICONOGRAPHY

Use one consistent icon family.

Do not mix:

```text
Outlined icons
+
Filled icons
+
3D icons
+
Random icon libraries
```

unless intentionally designed.

### Icon rules

* Icons should have consistent stroke weight.
* Use familiar symbols.
* Do not use icons when their meaning is ambiguous.
* Add labels when necessary.
* Do not replace critical text with icons alone.

---

# 31. CARDS

Cards are useful for grouping related content.

Do not put every piece of information inside a card.

### Good card

```text
┌────────────────────────────┐
│ Service Name               │
│ Short description          │
│                            │
│ ₹1,500                     │
│                            │
│ [ Book Now ]               │
└────────────────────────────┘
```

Cards should represent meaningful content groups.

---

# 32. BORDER RADIUS

Use a consistent radius system.

Example:

```text
Small:
6px

Medium:
8px

Large:
12px

Extra Large:
16px

Pills:
999px
```

Do not randomly mix:

```text
3px
7px
11px
15px
21px
```

---

# 33. SHADOWS

Use shadows sparingly.

Shadows should communicate:

* Elevation
* Layering
* Focus
* Floating elements

Avoid excessive shadows on every component.

Modern interfaces often use:

```text
Subtle shadow
+
Border
+
Surface contrast
```

instead of heavy shadows.

---

# 34. IMAGES

Images should support the user's goal.

Use:

* Correct aspect ratio
* Consistent cropping
* High-quality assets
* Meaningful placeholders
* Lazy loading where appropriate

Avoid stretched images.

Use appropriate image treatments:

```text
Cover
Contain
Crop
Aspect Ratio
```

---

# 35. CONTENT DESIGN

Good UX requires good content.

Use:

* Short sentences
* Clear labels
* Familiar language
* Action-oriented wording
* Consistent terminology

### Avoid

```text
Proceed with the aforementioned operation
```

### Prefer

```text
Continue
```

---

# 36. MICROCOPY

Small pieces of text have a major UX impact.

Examples:

```text
Button:
Book Appointment

Placeholder:
Search services...

Helper:
PDF, JPG or PNG up to 5 MB

Error:
Please enter a valid phone number.

Success:
Your profile was updated.
```

---

# 37. ACCESSIBILITY

Accessibility must be considered from the beginning.

### Check:

* Color contrast
* Font size
* Touch targets
* Keyboard navigation
* Screen readers
* Focus states
* Form labels
* Error messages
* Motion sensitivity
* Alternative text

Never depend only on:

```text
Color
Sound
Animation
Position
```

to communicate important information.

---

# 38. FOCUS STATES

Keyboard and accessibility users must know which element is active.

Every interactive element should have a visible focus state.

Example:

```text
Normal

[ Continue ]

Focused

[ ◉ Continue ]
```

---

# 39. ANIMATION

Animation should have a purpose.

Use animation to communicate:

* Transition
* Feedback
* Hierarchy
* Progress
* State change

Avoid animation merely because it looks cool.

### Good

```text
Button
→ Loading
→ Success
```

### Bad

Continuous unnecessary animations everywhere.

---

# 40. ANIMATION TIMING

Use subtle and predictable transitions.

Typical range:

```text
Micro interaction:
100–200ms

Component transition:
200–300ms

Large transition:
300–500ms
```

Avoid unnecessarily slow animations.

---

# 41. MOTION PRINCIPLES

Animation should:

```text
Start quickly
Move naturally
Finish clearly
```

Avoid:

```text
Long delays
Excessive bouncing
Unnecessary spinning
Continuous movement
```

Respect reduced-motion preferences where supported.

---

# 42. SEARCH UX

Search should provide:

* Clear search field
* Search icon
* Placeholder
* Suggestions when useful
* Recent searches when useful
* Loading state
* No-results state
* Clear button

### No results

```text
No results found

Try a different keyword or check your spelling.

[ Clear Search ]
```

---

# 43. FILTERS & SORTING

Make filters understandable.

Example:

```text
Filter
├── Category
├── Price
├── Rating
└── Availability
```

Show active filters clearly.

Example:

```text
Category: Plumbing ×
Price: ₹500–₹2,000 ×
```

Provide:

```text
Clear All
```

when multiple filters are applied.

---

# 44. TABLES & DATA-DENSE UI

For dashboards and admin panels:

Prioritize:

```text
Important information
↓
Actions
↓
Secondary information
```

Use:

* Sorting
* Filtering
* Pagination
* Search
* Sticky headers
* Row actions
* Status indicators

Avoid overwhelming users with every available field.

---

# 45. DASHBOARD DESIGN

A dashboard should answer:

1. What is happening?
2. What requires attention?
3. What changed?
4. What should I do next?

Recommended structure:

```text
Header
↓
Important KPI / Summary
↓
Primary Activity
↓
Charts / Insights
↓
Recent Activity
↓
Secondary Information
```

Do not fill dashboards with charts just to make them look advanced.

---

# 46. DESIGNING FOR TRUST

Trust is essential for:

* Payments
* Healthcare
* Education
* Finance
* Authentication
* Bookings
* Personal information

Use:

* Clear pricing
* Clear policies
* Confirmation messages
* Secure indicators where appropriate
* Transparent errors
* Predictable actions
* Consistent branding

Never hide important information.

---

# 47. DESTRUCTIVE ACTIONS

Use destructive styling carefully.

Examples:

```text
Delete
Remove
Cancel Subscription
Logout
Reset
```

Use:

```text
Clear wording
+
Appropriate visual warning
+
Confirmation when necessary
```

---

# 48. UNDO VS CONFIRMATION

Prefer undo when possible.

Instead of:

```text
Are you sure you want to delete this?
```

Consider:

```text
Item deleted.

[ Undo ]
```

This reduces unnecessary interruption.

---

# 49. NOTIFICATIONS

Notifications should be:

* Relevant
* Timely
* Understandable
* Actionable

Avoid unnecessary notifications.

Every notification should answer:

```text
What happened?
Why does it matter?
What can I do?
```

---

# 50. PERMISSION UX

Do not ask for permissions before explaining why they are needed.

### Bad

```text
Allow Camera?
```

### Better

```text
Scan your ID

We need camera access to scan your document.

[ Continue ]
```

Then request permission.

---

# 51. ONBOARDING

Onboarding should teach only what users need to know.

Avoid:

```text
10+ onboarding screens
```

Prefer:

```text
Value
↓
Core Feature
↓
First Useful Action
```

Good onboarding gets users to their first meaningful success quickly.

---

# 52. LOGIN & REGISTRATION

Keep authentication simple.

Prefer:

```text
Email / Phone
Password or OTP
```

Use social login when appropriate.

Avoid requesting unnecessary information during registration.

Collect additional information later when needed.

---

# 53. OTP UX

OTP screens should include:

```text
Phone / Email confirmation
OTP fields
Countdown
Resend option
Edit contact option
Error state
Loading state
```

Do not make users manually enter an OTP when secure automatic detection is available.

---

# 54. PAYMENT UX

Payment flows must be extremely clear.

Show:

```text
Order
+
Price
+
Taxes
+
Discount
+
Final Amount
+
Payment Method
+
Confirmation
```

Before payment, users should know exactly what they are paying.

---

# 55. PERFORMANCE UX

Performance is part of UX.

Optimize:

* Initial loading
* Image loading
* API requests
* Lists
* Animations
* Navigation
* Search
* Database queries

Users should see useful progress rather than a blank screen.

---

# 56. PERCEIVED PERFORMANCE

Even when an operation takes time:

```text
Immediate feedback
+
Progress indicator
+
Useful content
+
Clear completion
```

makes the experience feel faster.

---

# 57. DESIGN CONSISTENCY

Create reusable components.

Example:

```text
Design System
│
├── Colors
├── Typography
├── Spacing
├── Buttons
├── Inputs
├── Cards
├── Dialogs
├── Navigation
├── Icons
├── Tables
├── Lists
└── Feedback
```

Do not redesign the same component differently on every screen.

---

# 58. COMPONENT REUSE

Before creating a new component, ask:

> Does an existing component already solve this problem?

Prefer:

```text
Reusable Button
Reusable Input
Reusable Card
Reusable Dialog
Reusable AppBar
Reusable BottomSheet
Reusable EmptyState
Reusable LoadingState
```

This improves:

* Consistency
* Development speed
* Maintainability
* Accessibility
* QA

---

# 59. DESIGN TOKENS

Use design tokens rather than hardcoded values.

Example:

```text
color.primary
color.background
color.surface
color.error

spacing.xs
spacing.sm
spacing.md
spacing.lg

radius.sm
radius.md
radius.lg

font.heading
font.body
font.caption
```

This makes redesigns significantly easier.

---

# 60. DESIGN SYSTEM STRUCTURE

Recommended:

```text
Design System
│
├── Foundations
│   ├── Colors
│   ├── Typography
│   ├── Spacing
│   ├── Grid
│   ├── Radius
│   ├── Shadows
│   └── Icons
│
├── Components
│   ├── Buttons
│   ├── Inputs
│   ├── Cards
│   ├── Dialogs
│   ├── Navigation
│   └── Feedback
│
├── Patterns
│   ├── Authentication
│   ├── Forms
│   ├── Search
│   ├── Checkout
│   └── Dashboard
│
└── Screens
    ├── Home
    ├── Profile
    ├── Settings
    └── Feature Screens
```

---

# 61. DESIGN PROCESS

Use this process for every project.

```text
01. Understand
      ↓
02. Research
      ↓
03. Define User
      ↓
04. Define Goals
      ↓
05. Create User Flow
      ↓
06. Information Architecture
      ↓
07. Wireframes
      ↓
08. Design System
      ↓
09. High-Fidelity UI
      ↓
10. Prototype
      ↓
11. Usability Testing
      ↓
12. Developer Handoff
      ↓
13. Implementation
      ↓
14. QA
      ↓
15. Iterate
```

---

# 62. WIREFRAME FIRST

Do not immediately start with colors and shadows.

First validate:

```text
Layout
Hierarchy
Navigation
Content
Actions
Flow
```

Then apply visual design.

---

# 63. HIGH-FIDELITY DESIGN

After the flow is validated, add:

* Brand colors
* Typography
* Icons
* Images
* Component styles
* Spacing
* Animation
* States

---

# 64. USABILITY TESTING

Before development, test the prototype with real users when possible.

Ask users to perform realistic tasks.

Example:

```text
"Book a psychologist appointment for tomorrow."
```

Do not explain the interface beforehand.

Observe:

* Where they click
* What they misunderstand
* Where they hesitate
* What they expect
* Where they get stuck

---

# 65. HEURISTIC UX REVIEW

Review every screen using these questions:

### Visibility

Can users understand what is happening?

### Match

Does the interface use familiar language?

### Control

Can users undo or go back?

### Consistency

Does the same thing behave the same everywhere?

### Error Prevention

Can mistakes be prevented?

### Recognition

Do users recognize options instead of remembering them?

### Flexibility

Can experienced users move faster?

### Minimalism

Is unnecessary information removed?

### Recovery

Can users recover from errors?

### Help

Is assistance available when necessary?

---

# 66. SCREEN REVIEW CHECKLIST

For every screen ask:

```text
□ What is the user's goal?
□ Is the page purpose obvious?
□ Is the primary action obvious?
□ Is the hierarchy clear?
□ Is navigation predictable?
□ Is spacing consistent?
□ Is typography readable?
□ Is contrast sufficient?
□ Are touch targets large enough?
□ Are labels understandable?
□ Are loading states designed?
□ Are error states designed?
□ Are empty states designed?
□ Is success feedback designed?
□ Is the screen responsive?
□ Is accessibility considered?
□ Is unnecessary content removed?
```

---

# 67. EDGE CASE DESIGN

Do not design only the perfect scenario.

Design:

```text
Normal
Loading
Empty
Error
Offline
Permission denied
Slow network
Invalid input
Long text
Short text
Large numbers
No image
Broken image
Many items
One item
Zero items
Duplicate items
Expired session
Unauthorized access
```

---

# 68. CONTENT EDGE CASES

Always test:

```text
Short title
Very long title

Short username
Very long username

₹100
₹1,00,00,000

1 item
1,000 items

Small image
Large image

Short paragraph
Long paragraph
```

A design that works only with sample data is not production-ready.

---

# 69. SECURITY UX

Security should be understandable.

Examples:

```text
Session expired
Please sign in again.

Payment verification required.

Your account has been temporarily locked.
```

Avoid exposing technical errors such as:

```text
NullPointerException
500 Internal Server Error
FirebaseAuthException
```

Users need understandable messages.

---

# 70. OFFLINE UX

If the application can work offline, clearly communicate:

```text
Offline
```

and indicate which functionality is available.

Example:

```text
You're offline.

Your saved content is still available.
```

When connection returns:

```text
✓ Back online
```

---

# 71. ACCESSIBILITY CHECKLIST

Before release:

```text
□ Text is readable
□ Contrast is sufficient
□ Focus states exist
□ Interactive areas are large enough
□ Icons have meaningful labels where required
□ Images have alternative descriptions where appropriate
□ Forms have proper labels
□ Errors are announced clearly
□ Color is not the only indicator
□ Motion can be reduced
□ Keyboard navigation works where applicable
```

---

# 72. MOBILE UI CHECKLIST

```text
□ One-hand usability considered
□ Bottom actions are reachable
□ Navigation is predictable
□ Keyboard does not hide important content
□ Scroll behavior is natural
□ Safe areas are respected
□ Buttons are easy to tap
□ Text is readable
□ Loading states exist
□ Offline states exist
```

---

# 73. WEB UI CHECKLIST

```text
□ Responsive layout
□ Desktop navigation
□ Tablet layout
□ Mobile layout
□ Keyboard accessibility
□ Hover states
□ Focus states
□ Browser compatibility
□ Proper content width
□ No unnecessary horizontal scrolling
```

---

# 74. FLUTTER-SPECIFIC UI GUIDELINES

For Flutter projects:

### Prefer

```text
ThemeData
ColorScheme
TextTheme
MediaQuery
LayoutBuilder
SafeArea
Reusable Widgets
Design Tokens
```

### Avoid

```text
Hardcoded colors everywhere
Hardcoded font sizes everywhere
Repeated widget code
Large monolithic build() methods
Screen-specific random spacing
```

Recommended structure:

```text
lib/
├── core/
│   ├── theme/
│   ├── constants/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── authentication/
│   ├── home/
│   ├── profile/
│   └── settings/
│
└── main.dart
```

---

# 75. REACT-SPECIFIC UI GUIDELINES

For React projects:

Prefer reusable:

```text
Button
Input
Modal
Card
Table
Dropdown
Toast
Loader
EmptyState
```

Use a centralized design system:

```text
tokens/
components/
layouts/
patterns/
pages/
```

Avoid duplicating styles across individual pages.

---

# 76. DEVELOPER HANDOFF

Every design should provide:

```text
Screen
Component
States
Spacing
Typography
Colors
Assets
Interactions
Responsive behavior
Error behavior
Loading behavior
```

Developers should not have to guess:

```text
"What happens when I click this?"
"What happens while loading?"
"What happens when this fails?"
"What happens on mobile?"
```

---

# 77. DESIGN-TO-DEVELOPMENT CHECKLIST

Before handoff:

```text
□ All screens completed
□ All states completed
□ Components documented
□ Colors defined
□ Typography defined
□ Spacing defined
□ Assets exported
□ Icons identified
□ Responsive behavior defined
□ Interaction behavior defined
□ Error states defined
□ Loading states defined
□ Empty states defined
□ Success states defined
□ Accessibility reviewed
```

---

# 78. QA DESIGN REVIEW

After development, compare implementation against design.

Check:

```text
Visual
├── Typography
├── Colors
├── Spacing
├── Alignment
├── Icons
├── Images
└── Components

Interaction
├── Navigation
├── Buttons
├── Forms
├── Dialogs
├── Loading
├── Errors
└── Animations

Responsive
├── Mobile
├── Tablet
└── Desktop
```

---

# 79. THE 8-SECOND RULE

When a user opens a new screen, they should quickly understand:

```text
Where am I?
What is this?
What can I do?
What should I do next?
```

If users cannot answer these quickly, simplify the interface.

---

# 80. THE 3-SECOND ACTION RULE

The most important action should be visually discoverable almost immediately.

Example:

```text
Booking Page

"Book Appointment"
        ↓
[ Select Date ]
```

Do not hide the main action below unnecessary content.

---

# 81. REDUCE COGNITIVE LOAD

Reduce the amount users need to think about.

Use:

```text
Defaults
Suggestions
Autocomplete
Progressive Disclosure
Clear Labels
Logical Grouping
Familiar Patterns
```

Avoid:

```text
Too many choices
Too many colors
Too many actions
Long forms
Unclear terminology
Unnecessary steps
```

---

# 82. PROGRESSIVE DISCLOSURE

Do not show everything at once.

Example:

```text
Basic Information
        ↓
More Options
        ↓
Advanced Settings
```

Advanced features should not overwhelm beginners.

---

# 83. FAMILIAR PATTERNS

Prefer established patterns over clever inventions.

Examples:

```text
Search → Magnifying glass
Settings → Gear
Back → Arrow
Delete → Trash
Profile → Person
Menu → Three lines
```

Users should not have to learn basic interface conventions.

---

# 84. CONSISTENT TERMINOLOGY

Choose one term and use it everywhere.

Bad:

```text
Booking
Appointment
Reservation
Schedule
```

if they all mean the same thing.

Choose:

```text
Appointment
```

and use it consistently.

---

# 85. MINIMALISM

Minimalism does not mean removing useful information.

It means:

> Remove everything that does not help the user accomplish the task.

Every element should have a reason to exist.

Ask:

```text
Does this help the user?
```

If not:

```text
Remove it.
```

---

# 86. VISUAL BALANCE

Avoid:

```text
Too much empty space
Too much content
Uneven alignment
Random spacing
Unbalanced cards
```

Use:

```text
Grid
Alignment
Spacing
Grouping
Contrast
Hierarchy
```

---

# 87. ALIGNMENT

Choose consistent alignment.

Common:

```text
Left aligned content
Centered hero content
Right aligned numerical values
```

Avoid randomly mixing alignment without purpose.

---

# 88. 60/30/10 VISUAL BALANCE

As a starting point:

```text
60% → Primary/background surfaces
30% → Secondary surfaces/content
10% → Accent / emphasis
```

This is a guideline, not a strict mathematical rule.

---

# 89. VISUAL FOCUS

Every screen should have a visual focal point.

Examples:

```text
Dashboard
→ Important KPI

Booking
→ Select appointment

Checkout
→ Final payment amount

Profile
→ User identity
```

Do not give every element equal visual weight.

---

# 90. DESIGN QUALITY FORMULA

A useful mental model:

```text
Good UI
=
Clarity
+
Consistency
+
Hierarchy
+
Accessibility
+
Feedback
+
Responsiveness
```

And:

```text
Good UX
=
Easy to Understand
+
Easy to Use
+
Easy to Recover
+
Easy to Complete
```

---

# 91. FINAL DESIGN REVIEW

Before considering a design complete, ask:

### UX

```text
□ Can a new user understand this?
□ Is the primary task obvious?
□ Are there unnecessary steps?
□ Can users recover from mistakes?
□ Are important states handled?
```

### UI

```text
□ Is hierarchy clear?
□ Is spacing consistent?
□ Is typography consistent?
□ Are colors meaningful?
□ Are components consistent?
```

### Accessibility

```text
□ Is text readable?
□ Is contrast sufficient?
□ Are controls accessible?
□ Is color not the only signal?
□ Are focus states available?
```

### Responsive

```text
□ Mobile
□ Tablet
□ Desktop
```

### Engineering

```text
□ Components reusable?
□ Tokens centralized?
□ States documented?
□ Assets optimized?
□ Performance considered?
```

---

# 92. GOLDEN RULES

Always remember:

```text
01. Design for the user, not the designer.

02. Clarity beats creativity.

03. Consistency beats novelty.

04. Simplicity beats complexity.

05. Accessibility is not optional.

06. Every action needs feedback.

07. Every important screen needs loading,
    empty, error and success states.

08. Do not make users remember what the
    interface can show them.

09. Do not hide important actions.

10. Do not use decoration to compensate
    for poor usability.

11. Design edge cases before development.

12. Reuse components instead of reinventing them.

13. Use design tokens instead of random values.

14. Test the actual user flow, not just individual screens.

15. A beautiful interface that is difficult to use
    is not good UI/UX.
```

---

# 93. MASTER UI/UX CHECKLIST

Use this checklist before every project release.

```text
╔════════════════════════════════════════════╗
║              UI/UX FINAL CHECK             ║
╠════════════════════════════════════════════╣
║                                            ║
║ □ User goal is clear                       ║
║ □ User flow is simple                      ║
║ □ Information architecture is logical      ║
║ □ Primary action is obvious                ║
║ □ Visual hierarchy is clear                ║
║ □ Typography is consistent                 ║
║ □ Colors are semantic                      ║
║ □ Spacing follows the system               ║
║ □ Components are consistent                ║
║ □ Buttons have all states                  ║
║ □ Forms have validation                    ║
║ □ Loading states exist                     ║
║ □ Empty states exist                       ║
║ □ Error states exist                       ║
║ □ Success states exist                     ║
║ □ Offline states considered                ║
║ □ Accessibility reviewed                   ║
║ □ Responsive layouts tested                ║
║ □ Touch targets are sufficient             ║
║ □ Navigation is predictable                ║
║ □ Animations have a purpose                ║
║ □ Content is understandable                ║
║ □ Edge cases are handled                   ║
║ □ Performance considered                   ║
║ □ Developer handoff is complete            ║
║ □ Final implementation matches design      ║
║                                            ║
╚════════════════════════════════════════════╝
```

---

# 94. PROJECT DESIGN STANDARD

For every new project, create these documents:

```text
/docs
│
├── UI_UX_GUIDELINES.md
├── DESIGN_SYSTEM.md
├── USER_FLOWS.md
├── COMPONENTS.md
├── ACCESSIBILITY.md
└── RESPONSIVE_GUIDELINES.md
```

Recommended minimum:

```text
UI_UX_GUIDELINES.md
+
DESIGN_SYSTEM.md
+
USER_FLOWS.md
```

---

# 95. FINAL PRINCIPLE

> **Don't ask: "How can we make this screen look better?"**

Instead ask:

> **"How can we make this task easier, faster, clearer, safer, and more enjoyable for the user?"**

That question should guide every UI/UX decision.

---

## DESIGN DEFINITION OF DONE

A design is **DONE** only when:

```text
User can understand it
        +
User can use it
        +
User can recover from errors
        +
User can complete the task
        +
User can access it regardless of ability/device
        +
Developer can implement it without guessing
```

**If any of these are missing, the design is not finished.**
