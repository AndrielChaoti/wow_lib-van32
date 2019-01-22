# wow_lib-van32
<p><em><strong>Low Health Alarm. It does what the title says.</strong></em></p>
<h2 id="w-about">About</h2>
<p>This addon is desinged, quite simply, to just play a repeated and annoying sound when your health is below configured thresholds. You can set it up to use any sound you want, but it comes with a sound by default.</p>
<h2 id="w-configuration">Configuration</h2>
<p>You can get to the addon's settings by typing <strong>/lowhealth</strong>, <strong>/lh</strong> or <strong>/lha</strong> in chat, or opening the configuration in the Blizzard interface panel.</p>
<h3 id="w-speed-explanation">Speed explanation:</h3>
<p>The addon has configurable "speed" settings, which means, it can beep faster the lower health you are: the system works pretty simply, but here's an explanation:</p>
<ul>
<li>"Low" health will beep slowly (speed * multiplier)</li>
<li>"Dangerous" health will beep at a medium rate (speed)</li>
<li>"Critical" health will beep at a fast rate (speed / multiplier)</li>
</ul>
<h4 id="w-quick-setup-example">Quick Setup Example</h4>
<p>If you want your sound effect to play once every second, regardless of your health:</p>
<p><strong>Set the "Base Speed" to 1.0, and set the "Multiplier" to 1.</strong> This will set your sound effect to play every one second when your health is below the "Low" threshold, and it will not change between the other thresholds. A good example of this usage scenario is the Kingdom Hearts low health alarm, where it plays the siren sound constantly on low health.</p>
<p>If you want to play your sound faster the lower health you are:</p>
<p><strong>Set the "Base Speed" to your desired setting, and then set the multiplier to any number larger than 1.</strong> Currently, the multiplier setting does not support going below 1, so you cannot slow down the beeps the lower your health.</p>
<h2 id="w-problems-suggestions-bugs">Problems? Suggestions? Bugs?</h2>
<p>If you're having a problem with the addon, have a suggestion for a new feature, or you noticed a bug, just <a href="http://wow.curseforge.com/addons/low-health-alarm/tickets/">submit a ticket</a> and I'll try to get it fixed as fast as I can!</p>
