# --
# Copyright (C) 2001-2024 OTRS AG, https://otrs.com/
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
    my $TicketObject           = $Kernel::OM->Get('Kernel::System::Ticket');

    my $TicketID   = $ParamObject->GetParam( Param => 'TicketID' );
    my $ResponseID = $ParamObject->GetParam( Param => 'ResponseID' );

    my $StateGenerate = 0;
    my $NextStateName = 0;
    my $NextStateID   = 0;

    StateAtt:

    #compare config with current template screen id
    for my $TemplateName ( sort keys %{ $Param{ResponseTemplateDefaultState} } )
    {
        my $StandardTemplateID = $StandardTemplateObject->StandardTemplateLookup(
            StandardTemplate => $TemplateName,
        );

        if ( $ResponseID eq $StandardTemplateID ) {

            $NextStateName = $Param{ResponseTemplateDefaultState}{$TemplateName};
            $NextStateID   = $Kernel::OM->Get('Kernel::System::State')->StateLookup(
                State => $NextStateName,
            );

            if ($NextStateID)
            {
                $StateGenerate = 1;
                last StateAtt;
            }
        }
    }

    if ($StateGenerate)
    {
        my %Ticket = $TicketObject->TicketGet(
            TicketID => $TicketID,
            UserID   => 1,
        );

        #get value from process dropdown element
        my @OptionValues = ${ $Param{Data} } =~ /<select[^>]*id="StateID"[^>]*>(.*?)<\/select>/s;
        my @SelectValues = $OptionValues[0]  =~ /<option value="([^"]+)".*>/g;

        my @Lines = split /\n/, $OptionValues[0];
        my %PossibleNextStates;
        for my $Line (@Lines) {
            if ( $Line =~ /<option value="(\d+)">(.*?)<\/option>/ ) {
                my ( $Value, $Label ) = ( $1, $2 );
                $PossibleNextStates{$Value} = $Label;
            }
        }

        #new state selection based on reply template state config
        my $NewOutput = $LayoutObject->BuildSelection(
            Data          => \%PossibleNextStates,
            Name          => 'StateID',
            PossibleNone  => 1,
            Class         => 'Modernize',
            SelectedID    => $NextStateID,
            SelectedValue => $PossibleNextStates{$NextStateID},
            Title         => $Ticket{Title},
        );

        my $SearchFieldStart
            = quotemeta "<select class=\"Modernize\" id=\"StateID\" name=\"StateID\" title=\"$Ticket{Title}\">";
        my $SearchFieldEnd = quotemeta "</select>";
        my $ReturnField    = qq~$NewOutput
        ~;

        #search and replace
        ${ $Param{Data} } =~ s{$SearchFieldStart[\d\D]*?$SearchFieldEnd}{$ReturnField};

    }

    return 1;
}

1;
