import React from 'react';
import { TouchableOpacity, Platform } from 'react-native';
import { Ionicons as Icon } from '@expo/vector-icons';
import { Box, Text } from '../../theme/restyle';
import { useTheme } from '@shopify/restyle';
import { Theme } from '../../theme/theme';
import StatusBadge from './StatusBadge';

interface QuittanceCardProps {
  item: any;
  onPress: (item: any) => void;
  formatDate: (dateStr: string) => string;
  formatCurrency: (amount: number) => string;
}

export const QuittanceCard: React.FC<QuittanceCardProps> = ({ item, onPress, formatDate, formatCurrency }) => {
  const theme = useTheme<Theme>();

  return (
    <TouchableOpacity activeOpacity={0.8} onPress={() => onPress(item)}>
      <Box
        backgroundColor="cardBackground"
        marginHorizontal="m"
        marginVertical="s"
        borderRadius="l"
        padding="l"
        borderWidth={1}
        borderColor="borderLight"
        style={Platform.select({
          ios: { shadowColor: theme.colors.primary, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 12 },
          android: { elevation: 3 },
          web: { boxShadow: `0 4px 12px ${theme.colors.border}` as any }
        })}
      >
        {/* Header: Type + Status */}
        <Box flexDirection="row" justifyContent="space-between" alignItems="center" marginBottom="m">
          <Box flexDirection="row" alignItems="center">
            <Box backgroundColor="primaryBg" padding="s" borderRadius="m" marginRight="s">
              <Icon name="receipt" size={18} color={theme.colors.primary} />
            </Box>
            <Text variant="caption" color="primary" fontWeight="800" style={{ letterSpacing: 1, textTransform: 'uppercase' }}>
              Quittance
            </Text>
          </Box>
          <StatusBadge label={item.statut || 'Payée'} variant={item.statut_variant || 'success'} />
        </Box>
        
        {/* Quittance Number & Amount */}
        <Box flexDirection="row" justifyContent="space-between" alignItems="flex-end" marginBottom="m">
          <Box flex={1}>
            <Text variant="caption" color="textTertiary" marginBottom="xxs">N° de quittance</Text>
            <Text variant="title" fontWeight="900" fontSize={20} color="text">
              {item.numero || item.quittance || item.num_quittance || '-'}
            </Text>
          </Box>
          <Box alignItems="flex-end">
            <Text variant="title" fontWeight="900" fontSize={22} color="primary">
              {item.montantTotal || item.montant ? formatCurrency(item.montantTotal || item.montant) : '0,00'}
            </Text>
          </Box>
        </Box>

        <Box height={1} backgroundColor="borderLight" marginBottom="m" />

        {/* Details Grid */}
        <Box flexDirection="row" justifyContent="space-between">
          <Box flex={1} marginRight="m">
            <Box flexDirection="row" alignItems="center" marginBottom="xxs">
              <Icon name="document-text-outline" size={14} color={theme.colors.textTertiary} style={{ marginRight: 4 }} />
              <Text variant="caption" color="textTertiary">Police liée</Text>
            </Box>
            <Text variant="bodySmall" fontWeight="700" color="text">
              {item.police || '-'}
            </Text>
          </Box>

          <Box alignItems="flex-end">
            <Box flexDirection="row" alignItems="center" marginBottom="xxs">
              <Icon name="time-outline" size={14} color={theme.colors.textTertiary} style={{ marginRight: 4 }} />
              <Text variant="caption" color="textTertiary">Date d'échéance</Text>
            </Box>
            <Text variant="bodySmall" fontWeight="700" color="text">
              {formatDate(item.dateEcheance || item.date_echeance)}
            </Text>
          </Box>
        </Box>
      </Box>
    </TouchableOpacity>
  );
};
