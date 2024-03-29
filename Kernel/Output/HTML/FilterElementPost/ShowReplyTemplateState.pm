# --
# Copyright (C) 2022-2024 mo-azfar, https://github.com/mo-azfar
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Output::HTML::FilterElementPost::ShowReplyTemplateState;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::StandardTemplate',
    'Kernel::System::Web::Request',
    'Kernel::System::State',
    'Kernel::System::Ticket',
);

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $Action = $ParamObject->GetParam( Param => 'Action' );

    return 1 if !$Action;
    return 1 if !$Param{Templates}->{$Action};
    return 1 if !$Param{ResponseTemplateDefaultState};

    my $LayoutObject           = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $StandardTemplateObject = $Kernel::OM->Get('Kernel::System::StandardTemplate');
   
    my $ResponseID = $ParamObject->GetParam( Param => 'ResponseID' );
    my $NextStateName = 0;
    my $NextStateID   = 0;

    StateAtt:
    #compare config with current template screen id
    for my $TemplateName ( sort keys %{ $Param{ResponseTemplateDefaultState} } )
    {
        my $StandardTemplateID = $StandardTemplateObject->StandardTemplateLookup(
            StandardTemplate => $TemplateName,
        );

		next StateAtt if $ResponseID ne $StandardTemplateID;
		
        $NextStateName = $Param{ResponseTemplateDefaultState}{$TemplateName};
        $NextStateID   = $Kernel::OM->Get('Kernel::System::State')->StateLookup(
            State => $NextStateName,
        );

        if ($NextStateID)
        {	
			my $JS = qq~
					\$(document).ready(function() {
						\$('#StateID').val('$NextStateID').trigger('change'); 
					});       
			~;
			
			#add jquery onclick block
			$LayoutObject->AddJSOnDocumentComplete(
				Code => $JS,
			);
			
            last StateAtt;
        }
        
    }

    return 1;
}

1;
