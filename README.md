## Getting started

First setup your base url

```dart
void main() {
  leanApi.instance().setup(baseUrl: 'https://catfact.ninja/', showLogs: true);
  runApp(const MyApp());
}
```

## Fetch your data

```dart
    final Either<ApiFailure, CatModel> response = await cleanApi.get(
        fromJson: (json) => CatModel.fromJson(json), endPoint: 'fact');
 changeState = response.fold((l) => l.toString(), (r) => r.fact);
```
