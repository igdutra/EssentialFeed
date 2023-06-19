#  Notes around Substitutions in Composition.

In the SceneDelegate:

```

extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}

```

was replaced by 

```

return httpClient
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemsMapper.map)
```

So the file could be deleted.
Note: You change the behavior but you loose the custom error case for Connectivity from the RemoteLoader.

### RemoteFeedImageDataLoader
FeedImageDataMapper has no HTTPClientTaskWrapper, however no functionality was lost becase the cancel event is handled by the HTTPClient Publisher!
`.handleEvents(receiveCancel: { task?.cancel() })`


# Combine in Tests
* FeedProtocol was deleted because the only UseCase implementing it was the LocalFeedLoader.
* The `func loadPublisher() -> Publisher {` function in Combine Helpers was changed to be an extension only for the LocalFeedLoader
