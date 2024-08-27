### Design

- [Emre Seçer](https://dribbble.com/shots/7158704-Movie-App)

### About

![](readme/dynocoder-quote.png)

> Everything should be made as simple as possible, but not more. —Attributed to Albert Einstein (not sure about that...)

MVVM, VIPER, VIP, Clean Architecture, dependency injection... all of these approaches eventually lead to burnout...

They claim to provide benefits for large projects, yet their advocates never define what a "large project" is, resulting in every project adopting such (anti)patterns.

![](readme/ishouldbeworkingrn-quote.png)

I've worked professionally in 8 applications. 7 of them used MVVM, the last one used VIPER. None of them needed it.

This project is a playground for experimentation, marking my first step in moving away from industry madness and walking toward simpler, yet powerful, scalable, enjoyable, and maintainable development patterns (really, no marketing void promises as opposed to those used by the Clean Architecture crowd).

This is my take on "Simplicity Driven Development" philosophy (which isn't really my take, but rather the SwiftUI one...)

### Technical decisions/philosophy (heavily influenced by Jim Lai's articles/gists)

- Dynamic JSON instead of mirror objects of your api domain (app domain lives on the server, leave it there unless there's actually a need)
- Encapsulation over *Dependency Injection*
- Prioritizing simplicity and a small codebase over testability
- Smart refactoring instead of "one VM/Presenter per view" (tell me that scales...)
- Leveraging Native SDK rather than fighting it
- Using URLSession instead of unnecessary third-party libraries.
- Tailored, handcrafted code over unnecessary, cognitive taxing boilerplate
- "I won't needed it and If I do I'll smartly rewrite/migrate" instead of abstracting your persistency solution away "just in case"

About that last point, here's some basic advice:

- you need sync to a server?: Codable + FileSystem
- you need local persistence only?: Codable + FileSystem
- you don't need networking, but sync between devices?: CoreData/SwiftData + CloudKit

If you know before hand the answers to those questions (chances are you know about 100% of the time), you won't ever need to change your persistence solution...

![](readme/inkprk114-quote.png)
![](readme/adiga-cheezo-quote.png)

Thats all. Happy coding 👋

### Todo/WIP

- Persistence:
    - rating list
    - search/filter on locally saved lists
    - filter by category
    - pin
- Error state component
- Empty states components
- Search feature
- Tips
- Map Genres on backdrop cards component
- Accessibility
- Writting tests
- language specific fetch -> &language=es-ES
- Persist selectedTab
