
module Database.Kafkar.Stream
    ( kdecode
    , kencode
    ) where

import Control.Monad.Catch
import Control.Monad.Trans.Class
import Data.Binary
import Data.ByteString (ByteString)
import Pipes hiding (for)
import qualified Pipes.Binary as P
import qualified Pipes.Parse as P


-- FIXME (asayers): this throws an error on EOF
-- TODO (asayers): new name
kdecode :: MonadThrow m => Get a -> Producer ByteString m r -> Producer a m r
kdecode decoder input = do
    let handleErr (err, _rem) = lift $ throwM err
    handleErr =<< P.parsed (P.decodeGet decoder) input

-- TODO (asayers): new name
kencode :: Monad m => (a -> P.Put) -> Pipe a ByteString m ()
kencode encoder = P.encodePut . encoder =<< await



-- decoder1 :: Decoder a -> Consumer ByteString m (ByteString, Either String a)
-- decoder1 = go
--   where
--     go dec = case dec of
--       Done rem _ val -> return (rem, Right val)
--       Fail rem _ val -> return (rem, Left val)
--       Partial closure -> go . closure =<< await
