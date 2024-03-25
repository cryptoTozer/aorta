--[[
-- MEMEFRAMES 
-- Version: 0.3

-- NOTE: Requires token blueprint and staking blueprint to be loaded in order to run.

-- Install 

> .load-blueprint token
> .load-blueprint staking

> .load process/aorta.lua

Get-Info - Manpage
Get-Votes - return

]]
Votes = Votes or {}
-- $CRED
BuyToken = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
MaxMint = 1000000
Minted = Minted or 0
-- INITIAL FRAME ID
FrameID = FrameID or Inbox[1].FrameID 
-- INITIAL NAME
MEMEFRAME_NAME = MEMEFRAME_NAME or Inbox[1]["MemeFrame-Name"]

function Man (name) 
  return string.format([[
  v1

  # MemeFrames: %s

  Join the MemeFrame community. Mint MemeFrame Tokens using $CRED, then Stake them for voting on the Webpage to show
    on the MemeFrame page.

  ## Meme

  `MEME = "%s"`

  ## Mint

  ```
  Send({Target = CRED, Action = "Transfer", Quantity = "1000", Recipient = MEME  })
  ```

  ## Stake

  ```
  Send({Target = MEME, Action = "Stake", Quantity = "1000", UnstakeDelay = "1000"})
  ```

  ## Vote

  ```
  Send({Target = MEME, Action = "Vote", Side = "yay", VoteID = "{TXID}" })
  ```

  ## Get-Votes

  ```
  Send({Target = MEME, Action = "Get-Votes"})
  ```

]], name, ao.id)
end

-- GetInfo
Handlers.prepend("Get-Info", function (m) return m.Action == "Get-Info" end, function (m)
  Send({
    Target = m.From,
    Data = Man(Name)
  })
  print('Send Info to ' .. m.From)
end)

-- MINT
Handlers.prepend(
  "Mint",
  function(m)
    return m.Action == "Credit-Notice" and m.From == BuyToken
  end,
  function(m)
    local requestedAmount = tonumber(m.Quantity)
    local actualAmount = requestedAmount
    -- if over limit refund difference
    if (Minted + requestedAmount) > MaxMint then
      -- if not enough tokens available send a refund...
        Send({
          Target = BuyToken,
          Action = "Transfer",
          Recipient = m.Sender,
          Quantity = tostring(requestedAmount),
          Data = "Meme is Maxed - Refund"
        })
        print('send refund')
      Send({Target = m.Sender, Data = "Meme Maxed Refund dispatched"})
      return
    end
    assert(type(Balances) == "table", "Balances not found!")
    local prevBalance = tonumber(Balances[m.Sender]) or 0
    Balances[m.Sender] = tostring(math.floor(prevBalance + actualAmount))
    Minted = Minted + actualAmount
    print("Minted " .. tostring(actualAmount) .. " to " .. m.Sender)
    Send({Target = m.Sender, Data = "Successfully Minted " .. actualAmount})
  end
)

-- GET-FRAME
Handlers.prepend(
  "Get-Frame",
  Handlers.utils.hasMatchingTag("Action", "Get-Frame"),
  function(m)
    Send({
      Target = m.From,
      Action = "Frame-Response",
      Data = FrameID
    })
    print("Sent FrameID: " .. FrameID)
  end
)
