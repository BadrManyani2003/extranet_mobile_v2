import React from 'react';
import { TouchableOpacity, Platform } from 'react-native';
import { Ionicons as Icon } from '@expo/vector-icons';
import { Box, Text } from '../../theme/restyle';
import { useTheme } from '@shopify/restyle';
import { Theme } from '../../theme/theme';
import StatusBadge from './StatusBadge';

interface ContratCardProps {
  item: any;
  onPress: (item: any) => void;
  formatDate: (dateStr: string) => string;
}

export const ContratCard: React.FC<ContratCardProps> = ({ item, onPress, formatDate }) => {
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
        {/* Header: Status + Badge */}
        <Box flexDirection="row" justifyContent="space-between" alignItems="center" marginBottom="m">
          <Box flexDirection="row" alignItems="center">
            <Box backgroundColor="primaryBg" padding="s" borderRadius="m" marginRight="s">
              <Icon name="shield-checkmark" size={18} color={theme.colors.primary} />
            </Box>
            <Text variant="caption" color="primary" fontWeight="800" style={{ letterSpacing: 1, textTransform: 'uppercase' }}>
              {item.branche}
            </Text>
          </Box>
          <StatusBadge label={item.statut} variant={item.statut_variant || 'primary'} />
        </Box>

        {/* Police Number */}
        <Box marginBottom="m">
          <Text variant="caption" color="textTertiary" marginBottom="xxs">Numéro de police</Text>
          <Text variant="title" fontWeight="900" fontSize={20} color="text">
            {item.police}
          </Text>
        </Box>

        <Box height={1} backgroundColor="borderLight" marginBottom="m" />

        {/* Details Grid */}
        <Box flexDirection="row" justifyContent="space-between">
          <Box flex={1} marginRight="m">
            <Box flexDirection="row" alignItems="center" marginBottom="xxs">
              <Icon name="business-outline" size={14} color={theme.colors.textTertiary} style={{ marginRight: 4 }} />
              <Text variant="caption" color="textTertiary">Compagnie</Text>
            </Box>
            <Text variant="bodySmall" fontWeight="700" color="text" numberOfLines={1}>
              {item.compagnie}
            </Text>
          </Box>

          <Box alignItems="flex-end">
            <Box flexDirection="row" alignItems="center" marginBottom="xxs">
              <Icon name="calendar-outline" size={14} color={theme.colors.textTertiary} style={{ marginRight: 4 }} />
              <Text variant="caption" color="textTertiary">Date d'échéance</Text>
            </Box>
            <Text variant="bodySmall" fontWeight="700" color="text">
              {formatDate(item.dateEcheance)}
            </Text>
          </Box>
        </Box>
      </Box>
    </TouchableOpacity>
  );
};
