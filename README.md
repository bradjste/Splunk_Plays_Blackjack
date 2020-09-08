# Splunk_Plays_Blackjack
A utility application that models the game state of a blackjack table and transmits it via HTTP or UDP to a Splunk instance. 

Commissioned for "Splunk Plays Blackjack", presented at Splunk's .Conf 2019. 

To run, download Processing from https://processing.org/download and launch 'Splunk_plays_Blackjack.pde'.

Controls:
0: Face card
1-9: Respective values
ENTER: Changes to Splunk hand from Dealer's, or add's a card to Splunk's hand
.: Changes selected hand
+: New game
-: Remove card
/: Sends the game state over HTTP or UDP

Brad Stevenson, 2019
