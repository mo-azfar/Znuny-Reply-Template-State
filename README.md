# Znuny-Reply-Template-State
- set ticket state based on selected compose / answer / reply template

1. Update 'ResponseTemplateDefaultState'. Go to Admin > System Configuration > Frontend::Output::FilterElementPost###ShowReplyTemplateState

		ResponseTemplateDefaultState 
			
			Template Name => State Name
			
		*Where Template Name = response answer template name ( Admin > Templates )
		*Where State Name = ticket state name ( Admin > States )
			
		Example,
			
			Closed Ticket => closed successful
			Waiting for Customer Response => pending auto close+
			
		*Where Template name = 'Closed Ticket', selected ticket state will be 'closed successful'
		*Where Template name = 'Waiting for Customer Response', selected ticket state will be 'pending auto close+'
		
