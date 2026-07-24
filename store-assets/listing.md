# Chrome Web Store listing — paste-ready

## Name (max 75 chars)
Markgraf for GitHub

## Summary / short description (max 132 chars)
Renders ```markgraf fenced code blocks on GitHub as live, scrubbable animations — directly inline in READMEs, issues, and gists.

## Category
Developer Tools

## Language
English

## Detailed description (max 16,000 chars)
Markgraf is a tiny declarative language for animated graph diagrams — nodes, edges, and tokens that flow between them. This extension finds ```markgraf fenced code blocks on rendered GitHub markdown (READMEs, issues, PRs, comments, wikis, gists) and replaces each one with an inline animation player. Press play, scrub the timeline, watch the diagram evolve.

Everything runs locally in your browser. No accounts, no analytics, no network requests — the extension ships the entire renderer.

WHAT GETS RENDERED
• Any fenced code block whose info string is exactly: markgraf
• On github.com and gist.github.com (READMEs, issue/PR bodies and comments, wikis, gist files)
• Source view is preserved one click away — the original code is still there if you want to copy or edit it

WHY
Sequence diagrams and architecture diagrams are great until something starts moving. Markgraf is for the moving part: requests flowing through a service mesh, cache invalidations, retries, a writer waking up multiple readers. Authoring is a few lines per frame; the extension makes those animations playable wherever the source already lives.

PRIVACY
The extension collects no data. It makes no network requests. It uses no cookies and no browser storage. The only permissions requested are host access to github.com and gist.github.com, so it can find markgraf code blocks on pages you already visit. Full privacy notice: https://markgrafhq.github.io/markgraf-browser-extension/privacy

OPEN SOURCE
MIT-licensed. Source, issues, and releases: https://github.com/markgrafhq/markgraf-browser-extension

LEARN THE LANGUAGE
markgraf.dev walks through the syntax in about five minutes — frames, +node/-node, +edge/-edge, tokens with -> and <-, par/seq blocks.

## Single-purpose description
Render markgraf fenced code blocks as live, scrubbable animations on GitHub markdown surfaces.

## Permission justifications

### Host permission: https://github.com/* and https://gist.github.com/*
The extension's only job is to find ```markgraf fenced code blocks in rendered markdown on these two domains and replace them with the inline animation player. Access is limited to these hosts; the extension is not active on any other site. No data is read or transmitted off the page.

### Remote code
Not used. The extension bundles its renderer (`assets/markgraf-embed.js`) and runs only that local code. No remote scripts, eval, or dynamic imports.

## Data usage disclosures (developer dashboard checkboxes)
- Personally identifiable information: NO
- Health information: NO
- Financial and payment information: NO
- Authentication information: NO
- Personal communications: NO
- Location: NO
- Web history: NO
- User activity: NO
- Website content: NO

Certifications (all true):
- I do not sell or transfer user data to third parties, apart from the approved use cases
- I do not use or transfer user data for purposes that are unrelated to my item's single purpose
- I do not use or transfer user data to determine creditworthiness or for lending purposes

## Privacy policy URL
https://markgrafhq.github.io/markgraf-browser-extension/privacy

## Homepage URL
https://markgraf.dev

## Support URL
https://github.com/markgrafhq/markgraf-browser-extension/issues
