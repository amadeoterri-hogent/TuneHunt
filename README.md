<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->

<a id="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/amadeoterri-hogent/TuneHunt/">
    <img src="/images/tunehunt.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Tunehunt</h3>

  <p align="center">
    An awesome app to find new tunes and explore new artists
 </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

- Build a playlist which adds the top tracks of one single or multiple artists of your choice. Easily search for artists, and it will automatically add the top tracks of this artist into your playlist. This makes it a lot easier for you to find and listen to new tunes you like!

- Build a playlist by simply inserting an image, for example of your favorite festival. The app will automatically find the artists in the image and add the top tracks of these artists into your playlist. This way you can easily discover new artists and tunes!

- Build a playlist from top tracks of the artist of an existing playlist

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

[![Swift][Swift-img]][Swift-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

To get a local copy up and running follow these simple example steps.

### Prerequisites

- Xcode
- Spotify account

### Installation

_Below is an example of how you can instruct your audience on installing and setting up your app. This template doesn't rely on any external dependencies or services._

1. Go to [https://developer.spotify.com](https://developer.spotify.com)
2. Create an app https://developer.spotify.com/dashboard/create
3. Fill in app name and description
4. Fill in Redirect Uri

```sh
    tunehunt://login-callback #for your app
    http://localhost:8888/callback
    https://oauth.pstmn.io/v1/callback # for using postman
```

5. Fill in your bundle ID, the same as in the xcode project
6. Check iOS in Apis Used

7. Clone the repo
   ```sh
   git clone https://github.com/amadeoterri-hogent/TuneHunt.git
   ```
8. Open project in xcode
9. Add file config.plist
   9.1 Add key 'client_secret', type 'String' and your client secret from your app in [https://developer.spotify.com/dashboard](https://developer.spotify.com/dashboard)
   9.1 Add key 'client_id', type 'String' and your client id from your app in [https://developer.spotify.com/dashboard](https://developer.spotify.com/dashboard)
10. Startup the project
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->

## Roadmap

- [x] Native iOS app
- [x] Sufficiently complex
- [x] Best practices for SwiftUI
  - [x] Use existing views for structure.
  - [x] Use proper state management.
  - [x] Adopt the MVVM design pattern.
- [ ] Adaptive
- [x] iOS 16 or later.
- [x] Interact with a REST API
- [x] Add lecturer (svanimpe) as a collaborator.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## License

Distributed under the Unlicense License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Amadeo Terriere - amadeo.terriere@student.hogent.be

[![LinkedIn][linkedin-shield]][linkedin-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- [Hacking With Swift](https://www.hackingwithswift.com/)

- [Stanford - CS193p - Developing Apps for iOS](https://cs193p.sites.stanford.edu/2023)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/amadeoterriere/
[Swift-img]: https://camo.githubusercontent.com/9c6f59cc4af43a538bd6d5ade09234edf9cd8c81d8eeaf8987f90f1701d02529/68747470733a2f2f7777772e73776966742e6f72672f6173736574732f696d616765732f73776966747e6461726b2e737667
[Swift-url]: https://github.com/swiftlang/swift
