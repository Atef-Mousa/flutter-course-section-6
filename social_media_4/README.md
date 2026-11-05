# social_media_4: Dio Basics

A small demo that shows how an app talks to a server. Each button sends a different type of HTTP request, and the result appears on the screen.

> This project focuses on the **concepts**, so all the code is in one file (`lib/main.dart`) and it uses `Map` directly. For the cleaner structure with a model and a service, see [`wheather_app_1`](../wheather_app_1/README.md).

[Back to the section overview](../README.md)

---

## What you will learn

- Creating and configuring a `Dio` client
- Sending **GET, POST, PUT, PATCH and DELETE** requests
- Using **query parameters**
- Reading `response.statusCode` and `response.data`
- Converting a response to `Map<String, dynamic>`
- Catching `DioException` and handling each **error type**

---

## Run it

```bash
flutter pub get
flutter run
```

| Button | Function | Request | Shown on screen |
| --- | --- | --- | --- |
| refresh | `_getAllData` | `GET /posts?skip=10` | Title of the first post |
| Post new data | `_postNewData` | `POST /posts/add` | Status code and response |
| Put data | `_putData` | `PUT /posts/1` | Status code and response |
| Patch data | `_patchData` | `PATCH /posts/1` | Status code and response |
| Delete data | `_deleteData` | `DELETE /posts/1` | Status code and response |

> **DummyJSON is a practice API.** It only simulates changes. You get a real response, but nothing is saved on the server, so pressing "refresh" after a change still shows the old data.

---

## Step by step

### 1. Create the Dio client

We create it once and put the shared settings in `BaseOptions`.

```dart
final _dio = Dio(
  BaseOptions(
    baseUrl: "https://dummyjson.com",
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ),
);
```

| Option | Meaning |
| --- | --- |
| `baseUrl` | The start of every URL, so requests only need `/posts` |
| `connectTimeout` | The longest we wait to connect to the server |
| `receiveTimeout` | The longest we wait for the response |

### 2. GET: read data, with query parameters

```dart
var response = await _dio.get("/posts", queryParameters: {"skip": 10});
```

Dio builds the final URL for us: `https://dummyjson.com/posts?skip=10`. Here `skip` means "ignore the first 10 posts".

`await` matters because the network is slow. The function waits for the response without freezing the app. That is why these functions are `async` and return `Future<void>`.

### 3. Convert the response to a Map

The server sends JSON text. Dio turns it into Dart objects, and the JSON looks like this:

```json
{
  "posts": [
    { "id": 11, "title": "...", "body": "..." }
  ],
  "total": 251,
  "skip": 10,
  "limit": 30
}
```

So we read it one level at a time:

```dart
value = ((response.data as Map<String, dynamic>)["posts"] as List)[0]["title"];
```

| Part | Gives us |
| --- | --- |
| `response.data as Map<String, dynamic>` | The whole JSON object |
| `["posts"] as List` | The list of posts |
| `[0]` | The first post |
| `["title"]` | Its title |

This line is long and easy to get wrong. A typo in a key gives no warning until the app runs. Model classes solve this problem.

### 4. POST: create new data

```dart
var response = await _dio.post(
  "/posts/add",
  data: {"userId": 4, "username": "x", "password": "y"},
);
```

`data` is the request **body**. Dio converts the `Map` to JSON for us.

The response has status **`201 Created`**, not `200`, because something new was created:

```json
{ "id": 252, "userId": 4 }
```

Notice that `username` and `password` are gone. The server only kept the fields it knows for a post. A server decides what it accepts, so always check the API's documentation.

### 5. PUT and PATCH: update data

Both update the existing post with id `1`. The difference is how much we send.

```dart
// PUT: send the whole item
await _dio.put(
  "/posts/1",
  data: {"title": "new title", "body": "new body", "userId": 4},
);

// PATCH: send only what changed
await _dio.patch("/posts/1", data: {"title": "new title"});
```

| | PUT | PATCH |
| --- | --- | --- |
| Meaning | Replace the whole item | Change part of the item |
| What we send | All the fields | Only the changed fields |
| Success code here | `200` | `200` |

Press both buttons and compare the responses. With PATCH, `body` and `userId` keep their original values and only `title` changes.

### 6. DELETE: remove data

```dart
var response = await _dio.delete("/posts/1");
```

There is no body, because the URL already says which item to delete. DummyJSON answers `200` and returns the post with `"isDeleted": true`. Other APIs often answer `204 No Content` with an empty body.

### 7. Handle errors

Every request is inside `try` / `on DioException catch`, and every catch sends the error to one function:

```dart
try {
  var response = await _dio.delete("/posts/1");
  setState(() {
    value = "${response.statusCode} , ${response.data}";
  });
} on DioException catch (e) {
  setState(() {
    value = _handleError(e);
  });
}
```

`_handleError` reads `e.type` and returns a message the user can understand:

| `DioExceptionType` | Why it happens | Message in the app |
| --- | --- | --- |
| `connectionTimeout` | Could not connect in time | Request timed out, try again |
| `sendTimeout` | Sending took too long | Request timed out, try again |
| `receiveTimeout` | The response took too long | Request timed out, try again |
| `transformTimeout` | Processing the response took too long | Request timed out, try again |
| `connectionError` | No internet, or wrong host | No internet connection |
| `badCertificate` | The HTTPS certificate is not trusted | Security error (bad certificate) |
| `cancel` | The request was cancelled | Request cancelled |
| `badResponse` | The server replied with 4xx or 5xx | wrong info |
| `unknown` | Anything else | Unexpected network error |

Important points:

- Dio treats 4xx and 5xx as **exceptions**, so that code runs in `catch`, not in `try`.
- With `badResponse` the server did reply, so `e.response?.statusCode` has a value.
- With `connectionError` no reply arrived, so `e.response` is `null`. That is why we write `?.`.

For all the status codes and error types, see [`networking_notes.pdf`](../networking_notes.pdf).

---

## Try it yourself

1. **No internet:** turn off your internet and press any button. You should see "No internet connection".
2. **Wrong path:** change `/posts/1` to `/postsss/1`. The server replies `404`, so you should see "wrong info".
3. **Status code on errors:** change the `badResponse` message to `"wrong info ${e.response?.statusCode}"`, then repeat step 2.
4. **Timeout:** set `connectTimeout` to `Duration(milliseconds: 1)` and see which message appears.
5. **Query parameters:** add `"limit": 5` next to `"skip": 10`, then change the screen to show `response.data`. How many posts came back?
6. **New request:** add a button that gets one post with `GET /posts/5` and shows its title.

---

## Key takeaways

- The **URL** says which thing, and the **method** says what to do with it.
- `response.statusCode` says what happened, and `response.data` holds the data.
- Dio converts JSON to `Map` and `List` for you.
- Requests can fail at any time, so always use `try` / `catch`.
- Show users a clear message, not a technical error.
